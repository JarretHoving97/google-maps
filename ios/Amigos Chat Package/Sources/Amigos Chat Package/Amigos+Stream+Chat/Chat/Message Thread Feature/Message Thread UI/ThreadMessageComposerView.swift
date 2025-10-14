//
//  ThreadMessageComposerView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 07/10/2025.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

// a container view which is used to keep `StreamChat` out of scope
// We don't have our own approach for the `MessageComposerView` yet.
struct ThreadMessageComposerView: View {

    private let factory = CustomUIFactory()
    private let chatChannelController: ChatChannelController
    private let messageController: ChatMessageController

    @Binding var text: String
    @Binding var selectedRangeLocation: Int

    @Binding var quotedMessage: ChatMessage?
    @Binding var editedMessage: ChatMessage?

    private let onMessageSent: () -> Void

    public init(
        chatChannelController: ChatChannelController,
        messageController: ChatMessageController,
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping () -> Void
    ) {
        self.chatChannelController = chatChannelController
        self.messageController = messageController
        self._text = text
        self._selectedRangeLocation = selectedRangeLocation
        self._quotedMessage = quotedMessage
        self._editedMessage = editedMessage
        self.onMessageSent = onMessageSent
    }

    var body: some View {
        MessageComposerView(
            viewFactory: factory,
            channelController: chatChannelController,
            messageController: messageController,
            quotedMessage: $quotedMessage,
            editedMessage: $editedMessage,
            onMessageSent: onMessageSent
        )
    }
}

// MARK: Hiding reply in channel
extension CustomUIFactory {
    public func makeSendInChannelView(
        showReplyInChannel: Binding<Bool>,
        isDirectMessage: Bool
    ) -> some View {
        EmptyView()
    }
}
