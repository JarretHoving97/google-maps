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

class ChatViewControllerComposer {

    private init() {}

    /// - Parameter loadChannel: decides to set a callback that receives channel information to set channel information in the navigation view. (Set this to true if you need to open a channel directly)
    /// - Parameter chatClient: Chat object from stream API
    /// - Parameter channelId: unique Id so we can create a `ChatChannelController`
    /// - Parameter NavigationController: So we can add the Stream header in the title view.
    static func composeWith(
        chatClient: ChatClient,
        with channelId: String?,
        messageId: String?,
        channelCreationService: ChannelCreationService = RemoteFindOrCreateChannelService(),
        in navigationController: UINavigationController,
        loadChannel: Bool,
        showBackButtonInHeader: Bool = false
    ) -> CustomHostingController<ChatChannelScreen>? {

        if let channelId, let object = try? ChannelId(cid: channelId), let channelController = createChannelListController() {

            let channelViewController = composeWith(
                channelController: chatClient.channelController(for: object),
                channelListController: channelController, messageId: messageId,
                navigation: navigationController,
                loadChannel: loadChannel,
                showBackButtonInHeader: showBackButtonInHeader
            )

            channelViewController.rootView.onChatWithHostTapped = adaptOnChatWithHostTapped(
                 client: chatClient,
                 loader: MainTheadDispatchDecorator(decoratee: channelCreationService),
                 in: navigationController
             )

            channelViewController.navigationItem.largeTitleDisplayMode = .never

            return channelViewController
        }

        return nil
    }

    static private func composeWith(
        channelController: ChatChannelController,
        channelListController: ChatChannelListController,
        channelCreationService: ChannelCreationService = RemoteFindOrCreateChannelService(),
        messageId: String?,
        navigation: UINavigationController,
        loadChannel: Bool = true,
        showBackButtonInHeader: Bool = false
    ) -> CustomHostingController<ChatChannelScreen> {

        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController
        )
        let channelView = ChatChannelScreen(
            chatChannelController: channelController,
            viewModel: viewModel,
            messageId: messageId
        )
        let viewController = CustomHostingController(rootView: channelView)

        if loadChannel {
            viewController.rootView.onDidLoadChannel = adaptChannelToHeaderHandler(
                for: viewController,
                channelCreationService: channelCreationService,
                in: navigation,
                showBackButtonInHeader: showBackButtonInHeader
            )
        }

        return viewController
    }

    private static func createChannelListController() -> ChatChannelListController? {

        if let currentUserId = StreamChatWrapper.shared.client?.currentUserId {
            return StreamChatWrapper.shared.client!.channelListController(
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

    static func setChannelHeader(channel: ChatChannel, showBackButtonInHeader: Bool = false, for detailViewController: UIHostingController<ChatChannelScreen>, in navigationController: UINavigationController) {

        let channelView = CustomChannelHeaderView(
            viewFactory: CustomUIFactory.shared,
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

        /// show the back button when the current view is the `Root viewcontroller` of the `UINavigationcontroller` and the current view has no back button for it's self.
        /// We show the backbutton in this case when we present the chat as root view. (which has no backbutton by default)
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
        ExtendedStreamPlugin.shared.notifyNavigateBackToListeners(dismiss: true)
    }
}

// MARK: Adaptors
extension ChatViewControllerComposer {

    private static func routeToChannel(chatClient: ChatClient, messageId: String?, with navigationController: UINavigationController) -> ((ChatChannel) -> Void) {

        return { [ weak navigationController] chatChannel in
            guard let navigationController else { return }

            guard let detailViewController = composeWith(chatClient: chatClient, with: chatChannel.id, messageId: messageId, in: navigationController, loadChannel: false) else { return }
            ChatViewControllerComposer.setChannelHeader(channel: chatChannel, for: detailViewController, in: navigationController)
            navigationController.pushViewController(detailViewController, animated: true)
        }
    }

    static private func adaptOnChatWithHostTapped(client: ChatClient, loader: ChannelCreationService, in navigation: UINavigationController) -> ((String?) -> Void) {

        return { user in
            guard let user else { return }

            loader.load(for: user) { result in
                if case let .success(channel) = result {
                    let channelView = composeWith(
                        chatClient: client,
                        with: channel,
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
        for detailViewController: UIHostingController<ChatChannelScreen>,
        channelCreationService: ChannelCreationService,
        in navigation: UINavigationController,
        showBackButtonInHeader: Bool = false
    ) -> ((ChatChannel) -> Void) {
        return  { [weak navigation] channel in
            guard let navigation, navigation.navigationItem.titleView == nil else { return }
            setChannelHeader(
                channel: channel,
                showBackButtonInHeader: showBackButtonInHeader,
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
