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

public typealias MessageThreadNavigationAction = (MessageThreadChannelViewData) -> Void

public class ChatViewControllerComposer {

    private init() {}

    /// - Parameter chatClient: Chat object from stream API
    /// - Parameter channelId: unique Id so we can create a `ChatChannelController`
    /// - Parameter NavigationController: So we can add the Stream header in the title view.
    /// - Parameter routeHandler: inject route handling to communicate with the host app.
    /// - Parameter messageId: if we want to scroll to a specific message.
    /// - Parameter channelCreationService: Service to create a channel if it doesn't exist.
    /// - Parameter onWillMoveToParent: callback when the viewcontroller is about to move to parent.
    public static func composeWith(
        chatClient: ChatClient,
        chatChannel: ChatChannel,
        routeHandler: @escaping routeAction,
        messageId: String?,
        channelCreationService: ChannelCreationService = RemoteFindOrCreateChannelService(),
        in navigationController: UINavigationController,
        onWillMoveToParent: ((UIViewController?) -> Void)? = nil,
    ) -> UIHostingController<ChatChannelScreen>? {

        // Create detail viewcontroller to be shown
        RouteController.setupRouteAction(action: routeHandler)

        let viewModel = ChatChannelScreenViewModel(
            isDirectMessageChannel: chatChannel.isDirectMessageChannel
        )

        let channelController = chatClient.channelController(for: chatChannel.cid)

        let channelView = ChatChannelScreen(
            with: CustomUIFactory(),
            chatChannelController: channelController,
            viewModel: viewModel,
            messageId: messageId,
            messageThreadNavigationAction: { viewData in
                adaptRouteToMessageThread(with: viewData, client: chatClient, in: navigationController)
            }
        )

        let viewController = CustomHostingController(rootView: channelView)

        viewController.onWillMoveToParent = onWillMoveToParent

        // set navigation view if we have channeldata
        ChatNavigationHeaderComposer.setChannelHeader(
            with: CustomUIFactory(),
            viewModel: viewModel,
            channel: chatChannel,
            for: viewController,
            in: navigationController,
            onMoreTapped: adaptOnMoreTapped(
                viewModel: viewModel,
                in: navigationController
            )
        )

        // Handle header button navigation
        viewController.rootView.headerButtonTapHandler = adaptOnChannelHeaderButtonTap(
            client: chatClient,
            routeHandler: routeHandler,
            loader: MainTheadDispatchDecorator(decoratee: channelCreationService),
            in: navigationController
        )

        viewController.navigationItem.largeTitleDisplayMode = .never

        return viewController

    }

    ///  - Parameter viewFactory: CustomUIFactory to create the vieww with Stream UI.
    ///  - Parameter viewModel: ViewModel for the chat channel screen.
    ///  - Parameter channelController: Channel controller to load and observe channel data.
    ///  - Parameter routeHandler: inject route handling to communicate with the host app.
    ///  - Parameter messageId: if we want to scroll to a specific message.
    ///  - Parameter navigation: NavigationController to push the viewcontroller.
    ///  - Parameter onWillMoveToParent: callback when the viewcontroller is about to move to parent.
    ///
    ///  - Note: This method is useful when we want to show the chat screen first and load the channel data later.
    static public func lazyLoadCompose(
        viewFactory: CustomUIFactory,
        viewModel: ChatChannelScreenViewModel,
        channelController: ChatChannelController,
        routeHandler: @escaping routeAction,
        messageId: String?,
        navigation: UINavigationController,
        onWillMoveToParent: ((UIViewController?) -> Void)? = nil,
        client: ChatClient,
        channelCreationService: ChannelCreationService = RemoteFindOrCreateChannelService(),
    ) -> UIHostingController<ChatChannelScreen> {

        RouteController.setupRouteAction(action: routeHandler)

        let channelView = ChatChannelScreen(
            with: viewFactory,
            chatChannelController: channelController,
            viewModel: viewModel,
            messageId: messageId,
            messageThreadNavigationAction: { viewData in
                adaptRouteToMessageThread(
                    with: viewData,
                    client: client,
                    in: navigation
                )
            }
        )

        let viewController = CustomHostingController(rootView: channelView)

        viewController.onWillMoveToParent = onWillMoveToParent

        viewController.rootView.onDidLoadChannel = adaptChannelToHeaderHandler(
            viewFactory: viewFactory,
            viewModel: viewModel,
            for: viewController,
            in: navigation,
            onMoreTapped: adaptOnMoreTapped(
                viewModel: viewModel,
                in: navigation
            )
        )

        // Handle header button navigation
        viewController.rootView.headerButtonTapHandler = adaptOnChannelHeaderButtonTap(
            client: client,
            routeHandler: routeHandler,
            loader: MainTheadDispatchDecorator(decoratee: channelCreationService),
            in: navigation
        )

        return viewController
    }
}

// MARK: Adaptors
extension ChatViewControllerComposer {

    static private func adaptOnChannelHeaderButtonTap(
        client: ChatClient,
        routeHandler: @escaping routeAction,
        loader: ChannelCreationService,
        in navigation: UINavigationController
    ) -> HeaderButtonActionHandler {

        return { actionType in

            switch actionType {

            case let .messageHost(userId: userId):
                loader.load(for: userId) { result in
                    if case let .success(channel) = result, let channelId = try? ChannelId(cid: channel) {

                        let viewModel = ChatChannelScreenViewModel(isDirectMessageChannel: true)

                        let channelView = lazyLoadCompose(
                            viewFactory: CustomUIFactory(),
                            viewModel: viewModel,
                            channelController: client.channelController(for: channelId),
                            routeHandler: routeHandler,
                            messageId: nil,
                            navigation: navigation,
                            client: client
                        )
                        navigation.pushViewController(channelView, animated: true)
                    }
                }

            case let .startCommunityActivity(communityId: communityId):
                let route = "/upsert-activity?communityId=\(communityId)"
                RouteController.routeAction?(RouteInfo(route: .path(route), dismiss: true))
            }
        }
    }

    /// - Note: The action will set new channel information to the navigation title view.
    /// - Parameters: viewFactory: CustomUIFactory
    /// - Parameters: viewModel: ChatChannelScreenViewModel
    /// - Parameters: detailViewController: UIHostingController<ChatChannelScreen>
    /// - Parameters: channelCreationService: ChannelCreationService to create a channel if it doesn't exist.
    static private func adaptChannelToHeaderHandler(
        viewFactory: CustomUIFactory,
        viewModel: ChatChannelScreenViewModel,
        for detailViewController: UIHostingController<ChatChannelScreen>,
        in navigation: UINavigationController,
        onMoreTapped: @escaping onMoreTappedAction
    ) -> ((ChatChannel) -> Void) {

        return { [weak navigation] channel in
            guard let navigation, navigation.navigationItem.titleView == nil else { return }
            let showBackButtonInHeader = navigation.viewControllers.count <= 1
            ChatNavigationHeaderComposer.setChannelHeader(
                with: viewFactory,
                viewModel: viewModel,
                channel: channel,
                showBackButtonInHeader: showBackButtonInHeader,
                for: detailViewController,
                in: navigation,
                onMoreTapped: onMoreTapped
            )
        }
    }

    /// - Note: The action will set the viewModel's popOver to .moreActions
    /// - Note: The action will be triggered when the more button is tapped.
    /// - Parameters: viewModel: ChatChannelScreenViewModel
    /// - Parameters: navigation: UINavigationController
    /// - Returns: onMoreTappedAction
    private static func adaptOnMoreTapped(
        viewModel: ChatChannelScreenViewModel,
        in navigation: UINavigationController
    ) -> onMoreTappedAction {
        return { [weak viewModel] channel in
            guard let viewModel else { return }
            Task {
                await viewModel.toggle(popOver: .moreActions(channel))
            }
        }
    }

    private static func adaptRouteToMessageThread(
        with viewData: MessageThreadChannelViewData,
        client: ChatClient,
        in navigation: UINavigationController
    ) {
        do {

            let channelId = try ChannelId(cid: viewData.channelId)

            let channelController = client.channelController(for: channelId)

            let messageController = client.messageController(
                cid: channelId,
                messageId: viewData.messageId
            )

            let viewModel = MessageThreadChannelViewModel(
                messageController: messageController,
                channelController: channelController,
                navigationTitle: viewData.navigationTitle
            )

            let viewcontroller = UIHostingController(
                rootView: MessageThreadChannelView(viewModel: viewModel)
            )

            navigation.pushViewController(viewcontroller, animated: true)

        } catch {
            print("Could not create channelId: \(String(describing: error))")
        }
    }
}

// MARK: Decorators

/// Decorator to dispatch completion on main thread.
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

/// Decorate ChannelCreationService to dispatch on main thread.
extension MainTheadDispatchDecorator: ChannelCreationService where T == ChannelCreationService {

    func load(for user: String, completion: @escaping FindOrCreateChannelResult) {
        return decoratee.load(for: user, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}
