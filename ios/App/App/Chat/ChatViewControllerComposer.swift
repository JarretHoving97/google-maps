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
        in navigationController: UINavigationController,
        loadChannel: Bool,
        showBackButtonInHeader: Bool = false
    ) -> UIHostingController<ChatChannelScreen>? {

        if let channelId, let object = try? ChannelId(cid: channelId), let channelController = createChannelListController() {

            let channelViewController = composeWith(
                channelController: chatClient.channelController(for: object),
                channelListController: channelController, messageId: messageId,
                navigation: navigationController,
                loadChannel: loadChannel,
                showBackButtonInHeader: showBackButtonInHeader
            )

            channelViewController.navigationItem.largeTitleDisplayMode = .never

            return channelViewController
        }

        return nil
    }

    static private func composeWith(
        channelController: ChatChannelController,
        channelListController: ChatChannelListController,
        messageId: String?,
        navigation: UINavigationController,
        loadChannel: Bool = true,
        showBackButtonInHeader: Bool = false
    ) -> UIHostingController<ChatChannelScreen> {

        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController
        )
        let channelView = ChatChannelScreen(
            chatChannelController: channelController,
            viewModel: viewModel,
            messageId: messageId
        )
        let viewController = UIHostingController(rootView: channelView)

        if loadChannel {
            viewController.rootView.onDidLoadChannel = adaptChannelToHeaderHandler(for: viewController, in: navigation, showBackButtonInHeader: showBackButtonInHeader)
        }

        return viewController
    }

    static func adaptChannelToHeaderHandler(
        for detailViewController: UIHostingController<ChatChannelScreen>,
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

    private static func routeToChannel(chatClient: ChatClient, messageId: String?, with navigationController: UINavigationController) -> ((ChatChannel) -> Void) {

        return { [ weak navigationController] chatChannel in
            guard let navigationController else { return }

            guard let detailViewController = composeWith(chatClient: chatClient, with: chatChannel.id, messageId: messageId, in: navigationController, loadChannel: false) else { return }
            ChatViewControllerComposer.setChannelHeader(channel: chatChannel, for: detailViewController, in: navigationController)
            navigationController.pushViewController(detailViewController, animated: true)
        }
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
        ExtendedStreamPlugin.shared.notifyNavigateBackToListeners(dismiss: true)
    }
}
