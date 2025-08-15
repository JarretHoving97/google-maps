//
//  ExtendendStreamPlugin+.swift
//  App
//
//  Created by Jarret on 16/12/2024.
//

import UIKit
import StreamChat
import SwiftUI
import Amigos_Chat_Package

struct ChatPresentationModel {
    let channel: ChannelInfo
}

extension ExtendedStreamPlugin {

    func routeAction() -> routeAction {
        return { [weak self] routeInfo in
            self?.notifyNavigateToListeners(
                route: routeInfo.route?.value,
                dismiss: routeInfo.dismiss
            )
        }
    }

    private func adaptOnWillMoveToParent() -> ((UIViewController?) -> Void) {
        return { [weak self] parent in
            if parent == nil {
                self?.notifyNavigateBackToListeners(dismiss: false)
            }
        }
    }

    func composeNavigation(model: ChatPresentationModel? = nil) -> UINavigationController {
        if let channel = model?.channel {
            return buildStack(with: channel)
        }

        return build()
    }

    /// initialize chat if no instance can be found.
    func openChannel(info: ChannelInfo) {
        if ExtendedStreamPlugin.shared.chatNavigationController != nil {
            routeToChannel(with: info)
        } else {
            let model = ChatPresentationModel(
                channel: ChannelInfo(channelId: info.channelId)
            )
            initializeViewController(model: model)
        }
    }

    func routeToChannel(
        with channel: ChannelInfo,
        loadChannel: Bool = true,
        animated: Bool = true
    ) {

        guard let client = ExtendedStreamPlugin.chatClient.chatClient else { return }

        DispatchQueue.main.async { [weak chatNavigationController, weak self] in
            guard let self, let chatNavigationController, let channelController = try? client.channelController(for: ChannelId(cid: channel.channelId)) else { return }

            let detailViewController = ChatViewControllerComposer.lazyLoadCompose(
                viewFactory: CustomUIFactory(),
                viewModel: ChatChannelScreenViewModel(isDirectMessageChannel: channelController.channel?.isDirectMessageChannel ?? false),
                channelController: channelController,
                routeHandler: routeAction(),
                messageId: channel.messageId,
                navigation: chatNavigationController,
                client: client
            )

            chatNavigationController.pushViewController(detailViewController, animated: animated)
        }
    }

    private func adapRouteToChannel(
        messageId: String? = nil,
        with navigationController: UINavigationController
    ) -> ((ChatChannel) -> Void) {

        return { [ weak navigationController, weak self] chatChannel in
            guard let self, let navigationController else { return }

            guard let detailViewController = ChatViewControllerComposer.composeWith(
                chatClient: ExtendedStreamPlugin.chatClient.chatClient!,
                chatChannel: chatChannel,
                routeHandler: routeAction(),
                messageId: messageId,
                in: navigationController,
                onWillMoveToParent: adaptOnWillMoveToParent()
            ) else { return }

            navigationController.pushViewController(detailViewController, animated: true)
            notifyNavigateToListeners(route: "/channels/\(chatChannel.id)", dismiss: false)
        }
    }

    /// Sets navigation appearance globally in UIKit API.
    func setupNavigationAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()

        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.shadowColor = .clear

        let foregroundColor = UIColor(named: "Grey Dark")!
        let tintColor = UIColor(named: "Purple")!

        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: foregroundColor,
            .font: UIFont(name: "Poppins-Bold", size: 30)!,
            .baselineOffset: 12
        ]
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: foregroundColor,
            .font: UIFont(name: "Poppins-Bold", size: 15)!
        ]

        // Custom back image
        let backImage = UIImage(named: "amiBackButton")
        backImage?.withRenderingMode(.alwaysTemplate)
        navigationBarAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        // Remove back button text
        navigationBarAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navigationBarAppearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -50, vertical: 0)

        UINavigationBar.appearance().tintColor = tintColor
        UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        // MARK: Tabbar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.shadowColor = UIColor.clear
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
}

extension ExtendedStreamPlugin {

    private func build() -> UINavigationController {
        let channelViewController = ChatChannelsViewControllerComposer.composeWith(
            viewFactory: CustomUIFactory(),
            routeAction: routeAction(),
            onBackButtonTapped: { ExtendedStreamPlugin.shared.notifyNavigateBackToListeners(dismiss: true) }
        )

        let navigationController = UINavigationController(rootViewController: channelViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.modalPresentationStyle = .fullScreen

        channelViewController.rootView.onItemTapped = adapRouteToChannel(with: navigationController)

        return navigationController
    }

    private func buildStack(with channel: ChannelInfo) -> UINavigationController {

        guard let client = ExtendedStreamPlugin.chatClient.chatClient, let channelController = try? client.channelController(for: ChannelId(cid: channel.channelId)) else { return UINavigationController() }

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.modalPresentationStyle = .fullScreen

        let channelViewController = ChatChannelsViewControllerComposer.composeWith(
            viewFactory: CustomUIFactory(),
            routeAction: routeAction(),
            onBackButtonTapped: { ExtendedStreamPlugin.shared.notifyNavigateBackToListeners(dismiss: true) }
        )

        channelViewController.rootView.onItemTapped = adapRouteToChannel(with: navigationController)

        let chatViewController = ChatViewControllerComposer.lazyLoadCompose(
            viewFactory: CustomUIFactory(),
            viewModel: ChatChannelScreenViewModel(isDirectMessageChannel: channelController.channel?.isDirectMessageChannel ?? false),
            channelController: channelController,
            routeHandler: routeAction(),
            messageId: channel.messageId,
            navigation: navigationController,
            onWillMoveToParent: adaptOnWillMoveToParent(),
            client: client
        )

        let stack = [channelViewController, chatViewController].compactMap {$0}

        navigationController.setViewControllers(stack, animated: true)

        return navigationController
    }
}
