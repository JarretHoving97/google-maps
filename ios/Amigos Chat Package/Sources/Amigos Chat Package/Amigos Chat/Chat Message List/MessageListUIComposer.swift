//
//  MessageListUIComposer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 09/05/2025.
//

import Foundation
import SwiftUI

class MessageListUIComposer {

    static private var messageMapper = MessageMapper()

    @MainActor
    static func makeMessageListView(
        messages: [ChatMessageProtocol],
        messageDisplayConfig: MessageListDisplayConfiguration,
        messageGroupingInfo: [String: [String]],
        unreadMessagesCount: Int,
        scrollDirection: Binding<MessageListView.ScrollDirection>,
        isDirectMessageChat: Bool,
        firstUnreadMessageId: String?,
        isReadHandler: HasSeenHandler,
        isReadByAllHandler: @escaping IsReadByAllHandler,
        onMessageAppear: @escaping (Int, MessageListView.ScrollDirection) -> Void,
        onQuotedMessageTapHandler: @escaping QuotedMessageTapHandler,
        onMessageReplyHandler: @escaping MessageReplyHandler,
        onLongPressHandler: @escaping LongPressHandler,
        onReactionsTap: @escaping ReactionsTapHandler,
        width: CGFloat
    ) -> some View {

        let messageList = messages.map { messageMapper.map($0) }

        let viewModel = MessageListViewModel(
            messageList: messageList,
            unreadMessagesCount: unreadMessagesCount,
            messagesGroupingInfo: messageGroupingInfo,
            isDirectMessageChat: isDirectMessageChat,
            firstUnreadMessageId: firstUnreadMessageId,
            isReadHandler: isReadHandler,
            isReadByAllHandler: isReadByAllHandler,
            config: messageDisplayConfig
        )

        let messageGestureCallbacks = MessageGestureCallbacks(
            onQuotedMessageTap: onQuotedMessageTapHandler,
            onMessageReply: onMessageReplyHandler,
            onLongPress: onLongPressHandler,
            onReactionsTap: onReactionsTap
        )

        return MessageListView(
            viewModel: viewModel,
            callbacks: messageGestureCallbacks,
            width: width,
            scrollDirection: scrollDirection,
            onMessageAppear: onMessageAppear
        )
    }
}
