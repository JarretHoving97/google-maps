//
//  ChatChannelsViewControllerComposer.swift
//  App
//
//  Created by Jarret on 11/12/2024.
//

import UIKit
import SwiftUI
import StreamChat

public class ChatChannelsViewControllerComposer {

    private init() {}

    public static func composeWith(viewFactory: CustomUIFactory, routeAction: @escaping routeAction, onBackButtonTapped: (() -> Void)?) -> UIHostingController<ChatScreen> {

        RouteController.setupRouteAction(action: routeAction)

        let viewModel = ChatViewModel()
        let chatScreen = ChatScreen(
            with: viewFactory,
            channelListController: ChatControllers.channelListController!,
            chatViewModel: viewModel,
            onBackButtonTapped: onBackButtonTapped
        )
        let viewcontroller = UIHostingController(rootView: chatScreen)
        viewcontroller.title = viewModel.title

        return viewcontroller
    }
}
