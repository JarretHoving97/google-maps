//
//  MessageGestures.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/06/2025.
//

import Foundation

typealias LongPressHandler = ((LocalMessageInfo) -> Void)
typealias QuotedMessageTapHandler = ((String) -> Void)
typealias MessageReplyHandler = ((String) -> Void)
typealias ReactionsTapHandler = ((MessageReactionsInfo) -> Void)

struct MessageGestureCallbacks {

    var onQuotedMessageTap: QuotedMessageTapHandler
    var onMessageReply: MessageReplyHandler
    var onLongPress: LongPressHandler
    var onReactionsTap: ReactionsTapHandler

    init(
        onQuotedMessageTap: @escaping QuotedMessageTapHandler,
        onMessageReply: @escaping MessageReplyHandler,
        onLongPress: @escaping LongPressHandler,
        onReactionsTap: @escaping ReactionsTapHandler
    ) {
        self.onQuotedMessageTap = onQuotedMessageTap
        self.onMessageReply = onMessageReply
        self.onLongPress = onLongPress
        self.onReactionsTap = onReactionsTap
    }
}

extension MessageGestureCallbacks {

    static var noGestures: Self {
        MessageGestureCallbacks(
            onQuotedMessageTap: { _ in },
            onMessageReply: { _ in },
            onLongPress: { _ in },
            onReactionsTap: { _ in }
        )
    }
}
