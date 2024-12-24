//
//  ChatChannelsViewControllerComposer.swift
//  App
//
//  Created by Jarret on 11/12/2024.
//

import UIKit
import SwiftUI
import StreamChat

class ChatChannelsViewControllerComposer {

    private init() {}

    static func composeWith(onBackButtonTapped: (() -> Void)?) -> UIHostingController<ChatScreen> {
        let viewModel = ChatViewModel()
        let chatScreen = ChatScreen(chatViewModel: viewModel, onBackButtonTapped: onBackButtonTapped)
        let viewcontroller = UIHostingController(rootView: chatScreen)
        viewcontroller.title = viewModel.title

        return viewcontroller
    }
}
