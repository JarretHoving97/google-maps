//
//  ChannelActionsViewStreamContainer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/11/2025.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// A lightweight container that bridges Stream Chat actions and callbacks
/// into our own module. It converts Stream channel actions into our custom
/// view model and forwards them to `ChannelActionsView`.
struct ChannelActionsViewStreamContainer: View {

    let router: Router?

    let viewModel: CustomChannelActionViewModel

    let callbackActions: ChannelActionsView.CallBackActions

    init(
        router: Router? = nil,
        viewModel: CustomChannelActionViewModel,
        callbackActions: ChannelActionsView.CallBackActions = ChannelActionsView.CallBackActions()
    ) {
        self.router = router
        self.viewModel = viewModel
        self.callbackActions = callbackActions
    }

    init(
        router: Router? = nil,
        channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void,
        onClose: @escaping (ChannelActionCallbacks.Info?) -> Void) {
        self.router = router
        let callbacks = ChannelActionsView.CallBackActions(
            onDismiss: onDismiss,
            onError: onError,
            onClose: onClose
        )
        let actionCallbacks = ChannelActionCallbacks(from: callbacks)
        let channelActions = ChannelAction.customActions(for: channel, chatClient: chatClient, callbacks: actionCallbacks, router: router)
        self.viewModel = CustomChannelActionViewModel(from: channelActions)
        self.callbackActions = callbacks
    }

    var body: some View {
        ChannelActionsView(
            viewModel: viewModel,
            callbackActions: callbackActions
        )
    }
}
