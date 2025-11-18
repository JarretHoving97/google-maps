//
//  MessageComposerViewContainer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 11/11/2025.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

// most easy way to add a border to the composer view
public struct MessageComposerViewContainer<Factory: ViewFactory>: View {

    private let factory: Factory
    private let channelController: ChatChannelController
    private let messageController: ChatMessageController?
    private var quotedMessage: Binding<ChatMessage?>
    private var editedMessage: Binding<ChatMessage?>
    private var onMessageSent: () -> Void

    public init(
        factory: Factory,
        with channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping () -> Void
    ) {
        self.channelController = channelController
        self.messageController = messageController
        self.quotedMessage = quotedMessage
        self.editedMessage = editedMessage
        self.onMessageSent = onMessageSent
        self.factory = factory
    }

    public var body: some View {
        MessageComposerView(
            viewFactory: factory,
            channelController: channelController,
            messageController: messageController,
            quotedMessage: quotedMessage,
            editedMessage: editedMessage,
            onMessageSent: onMessageSent
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(.greyLight))
                .frame(height: 2)
                .allowsHitTesting(false)
        }
    }
}
