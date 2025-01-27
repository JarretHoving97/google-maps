//
//  ChatViewControllerComposer.swift
//  App
//
//  Created by Jarret on 11/12/2024.
//

import UIKit
import SwiftUI
import StreamChat
import StreamChatSwiftUI

public class ChatViewControllerComposer {

    private init() {}

    /// - Parameter loadChannel: decides to set a callback that receives channel information to set channel information in the navigation view. (Set this to true if you need to open a channel directly)
    /// - Parameter chatClient: Chat object from stream API
    /// - Parameter channelId: unique Id so we can create a `ChatChannelController`
    /// - Parameter NavigationController: So we can add the Stream header in the title view.
    public static func composeWith(
        chatClient: ChatClient,
        with channelId: String?,
        routeHandler: @escaping routeAction,
        messageId: String?,
        channelCreationService: ChannelCreationService = RemoteFindOrCreateChannelService(),
        in navigationController: UINavigationController,
        loadChannel: Bool,
        showBackButtonInHeader: Bool = false
    ) -> UIHostingController<ChatChannelScreen>? {

        if let channelId, let object = try? ChannelId(cid: channelId), let channelController = createChannelListController() {

            let channelViewController = composeWith(
                viewFactory: CustomUIFactory(),
                channelController: chatClient.channelController(for: object),
                channelListController: channelController,
                routeHandler: routeHandler,
                messageId: messageId,
                navigation: navigationController,
                loadChannel: loadChannel,
                showBackButtonInHeader: showBackButtonInHeader
            )


            channelViewController.rootView.onChatWithHostTapped = adaptOnChatWithHostTapped(
                client: chatClient,
                routeHandler: routeHandler,
                loader: MainTheadDispatchDecorator(decoratee: channelCreationService),
                in: navigationController
            )


            channelViewController.navigationItem.largeTitleDisplayMode = .never

            return channelViewController
        }

        return nil
    }

    static private func composeWith(
        viewFactory: CustomUIFactory,
        channelController: ChatChannelController,
        channelListController: ChatChannelListController,
        routeHandler: @escaping routeAction,
        messageId: String?,
        channelCreationService: ChannelCreationService = RemoteFindOrCreateChannelService(),
        navigation: UINavigationController,
        loadChannel: Bool = true,
        showBackButtonInHeader: Bool = false
    ) -> UIHostingController<ChatChannelScreen> {

        RouteController.setupRouteAction(action: routeHandler)

        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController
        )
        let channelView = ChatChannelScreen(
            with: viewFactory,
            chatChannelController: channelController,
            viewModel: viewModel,
            messageId: messageId
        )
        let viewController = UIHostingController(rootView: channelView)


        if loadChannel {
            viewController.rootView.onDidLoadChannel = adaptChannelToHeaderHandler(
                viewFactory: viewFactory,
                for: viewController,
                channelCreationService: channelCreationService,
                in: navigation,
                showBackButtonInHeader: showBackButtonInHeader
            )
        }

        return viewController
    }

    private static func createChannelListController() -> ChatChannelListController? {

        if let currentUserId = UserProvider.shared.id {
            return ChatControllers.set(
                query: .init(
                    filter: .and([
                        .equal(.type, to: .messaging),
                        .containMembers(userIds: [currentUserId]),
                        .exists(.lastMessageAt)
                    ])
                )
            )
        }
        return nil
    }

    public static func setChannelHeader(with viewFactory: CustomUIFactory, channel: ChatChannel, showBackButtonInHeader: Bool = false, for detailViewController: UIHostingController<ChatChannelScreen>, in navigationController: UINavigationController) {

        let channelView = CustomChannelHeaderView(
            viewFactory: viewFactory,
            channel: channel
        )
        .environmentObject(detailViewController.rootView.viewModel)

        let navView = UIHostingController(
            rootView: channelView
        ).view!

        navView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()

        // create stackview to have multiple views in navigation title view
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal

        // create a backbutton
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "amiBackButton"), for: .normal)
        backButton.addTarget(self, action: #selector(customBackAction), for: .touchUpInside)

        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(navView)

        container.addSubview(stackView)

        // determine if we need to show the backbutton in the header
        // we do not want to a back button when the current view is a root view in the UINavigationController
        backButton.isHidden = !showBackButtonInHeader
        detailViewController.navigationItem.titleView = container

        // auto layout
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            container.heightAnchor.constraint(equalToConstant: 44), // default navigation height
            container.widthAnchor.constraint(equalToConstant: navigationController.navigationBar.frame.width),

            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }

    @objc private static func customBackAction() {
        RouteController.routeAction?(.dismiss)
    }
}

// MARK: Adaptors
extension ChatViewControllerComposer {

    private static func routeToChannel(
        viewFactory: CustomUIFactory,
        chatClient: ChatClient,
        routeHandler: @escaping routeAction,
        messageId: String?,
        with navigationController: UINavigationController
    ) -> ((ChatChannel) -> Void) {

        return { [ weak navigationController] chatChannel in
            guard let navigationController else { return }

            guard let detailViewController = composeWith(
                chatClient: chatClient,
                with: chatChannel.id,
                routeHandler: routeHandler,
                messageId: messageId,
                in: navigationController,
                loadChannel: false
            ) else { return }

            ChatViewControllerComposer.setChannelHeader(
                with: viewFactory,
                channel: chatChannel,
                for: detailViewController,
                in: navigationController
            )
            navigationController.pushViewController(detailViewController, animated: true)
        }
    }

    static private func adaptOnChatWithHostTapped(client: ChatClient, routeHandler: @escaping routeAction, loader: ChannelCreationService, in navigation: UINavigationController) -> ((String?) -> Void) {

        return { user in
            guard let user else { return }

            loader.load(for: user) { result in
                if case let .success(channel) = result {

                    let channelView = composeWith(
                        chatClient: client,
                        with: channel,
                        routeHandler: routeHandler,
                        messageId: nil,
                        in: navigation,
                        loadChannel: true
                    )!
                    navigation.pushViewController(channelView, animated: true)
                }
            }
        }
    }

    static func adaptChannelToHeaderHandler(
        viewFactory: CustomUIFactory,
        for detailViewController: UIHostingController<ChatChannelScreen>,
        channelCreationService: ChannelCreationService,
        in navigation: UINavigationController,
        showBackButtonInHeader: Bool = false
    ) -> ((ChatChannel) -> Void) {
        return  { [weak navigation] channel in
            guard let navigation, navigation.navigationItem.titleView == nil else { return }
            setChannelHeader(
                with: viewFactory,
                channel: channel,
                for: detailViewController,
                in: navigation
            )
        }
    }
}


// MARK: Decorators

final class MainTheadDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }

        completion()
    }
}

extension MainTheadDispatchDecorator: ChannelCreationService where T == ChannelCreationService {

    func load(for user: String, completion: @escaping FindOrCreateChannelResult) {
        return decoratee.load(for: user, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}
