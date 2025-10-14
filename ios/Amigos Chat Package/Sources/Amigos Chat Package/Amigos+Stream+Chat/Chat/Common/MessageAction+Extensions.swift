import StreamChat
import SwiftUI
import StreamChatSwiftUI

public typealias ChannelControllerBuilder = ((ChatChannel, ChatMessage) -> ChatChannelController?)

extension MessageAction {
    /// Returns the default message actions.
    ///
    ///  - Parameters:
    ///     - message: the current message.
    ///     - chatClient: the chat client.
    ///     - onDimiss: called when the action is executed.
    ///  - Returns: array of `MessageAction`.
    public static func customActions<Factory: ViewFactory>(
        factory: Factory,
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        var messageActions = [MessageAction]()

        let messageController = chatClient.messageController(cid: channel.cid, messageId: message.id)

        let isInsideThreadView = messageController.replies.count > 0

        if channel.config.repliesEnabled && !message.isPartOfThread && !isInsideThreadView {
            let replyThread = threadReplyAction(
                factory: factory,
                for: message,
                channel: channel
            )
            messageActions.append(replyThread)
        }

        if message.localState == .sendingFailed {
            messageActions = messageNotSentActions(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            return messageActions
        } else if message.localState == .pendingSend
            && message.allAttachments.contains(where: { $0.uploadingState?.state == .uploadingFailed }) {
            messageActions = editAndDeleteActions(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            return messageActions
        } else if message.isBounced {
            let title = MessageAction(
                title: tr("message.bounce.title"),
                iconName: "",
                action: {},
                confirmationPopup: nil,
                isDestructive: false
            )
            messageActions = messageNotSentActions(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            messageActions.insert(title, at: 0)
            return messageActions
        }

        if channel.canQuoteMessage {
            let quoteAction = quoteAction(
                for: message,
                channel: channel,
                onFinish: onFinish
            )
            messageActions.append(quoteAction)
        }

        if !message.text.isEmpty {
            let copyAction = copyMessageAction(
                for: message,
                onFinish: onFinish
            )

            messageActions.append(copyAction)
        }

        let isOwnMessageMutable = abs(message.createdAt.timeIntervalSinceNow) <= TimeInterval(60 * 15)

        if channel.ownCapabilities.contains(.updateOwnMessage) && message.isSentByCurrentUser && isOwnMessageMutable {
            if message.poll == nil {
                let editAction = editMessageAction(
                    for: message,
                    channel: channel,
                    onFinish: onFinish
                )
                messageActions.append(editAction)
            }
        }

        let isOwnMessageDeletable = channel.ownCapabilities.contains(.deleteOwnMessage) &&
        message.isSentByCurrentUser &&
        isOwnMessageMutable

        let isAnyMessageDeletable = channel.ownCapabilities.contains(.deleteAnyMessage)

        if isOwnMessageDeletable || isAnyMessageDeletable {
            let deleteAction = deleteAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )

            messageActions.append(deleteAction)
        }

        if !message.isSentByCurrentUser && (!message.isPartOfThread || message.showReplyInChannel) {
            let markUnreadAction = markAsUnreadAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )

            messageActions.append(markUnreadAction)
        }

        return messageActions
    }

    // MARK: - private

    private static func copyMessageAction(
        for message: ChatMessage,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let copyAction = MessageAction(
            id: MessageActionId.copy,
            title: tr("message.actions.copy"),
            iconName: "",
            action: {
                UIPasteboard.general.string = message.adjustedText
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "copy"
                    )
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return copyAction
    }

    private static func editMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let editAction = MessageAction(
            id: MessageActionId.edit,
            title: tr("message.actions.edit"),
            iconName: "",
            action: {
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "edit"
                    )
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return editAction
    }

    private static func quoteAction(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let quoteAction = MessageAction(
            id: MessageActionId.reply,
            title: tr("message.actions.inline-reply"),
            iconName: "",
            action: {
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "inlineReply"
                    )
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return quoteAction
    }

    private static func deleteAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let messageController = chatClient.messageController(
            cid: channel.cid,
            messageId: message.id
        )

        let deleteAction = {
            messageController.deleteMessage { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "delete"
                        )
                    )
                }
            }
        }

        let deleteMessage = MessageAction(
            id: MessageActionId.delete,
            title: tr("message.actions.delete"),
            iconName: "",
            action: deleteAction,
            confirmationPopup: nil,
            isDestructive: true
        )

        return deleteMessage
    }

    private static func markAsUnreadAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let channelController = chatClient.channelController(for: channel.cid)
        let action = {
            channelController.markUnread(from: message.id) { result in
                if case let .failure(error) = result {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: MessageActionId.markUnread
                        )
                    )
                }
            }
        }
        let unreadAction = MessageAction(
            id: MessageActionId.markUnread,
            title: tr("message.actions.mark-unread"),
            iconName: "",
            action: action,
            confirmationPopup: nil,
            isDestructive: false
        )

        return unreadAction
    }

    private static func resendMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let messageController = chatClient.messageController(
            cid: channel.cid,
            messageId: message.id
        )

        let resendAction = {
            messageController.resendMessage { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "resend"
                        )
                    )
                }
            }
        }

        let messageAction = MessageAction(
            id: MessageActionId.resend,
            title: tr("message.actions.resend"),
            iconName: "",
            action: resendAction,
            confirmationPopup: nil,
            isDestructive: false
        )

        return messageAction
    }

    private static func messageNotSentActions(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        var messageActions = [MessageAction]()

        let resendAction = resendMessageAction(
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: onFinish,
            onError: onError
        )
        messageActions.append(resendAction)

        let editAndDeleteActions = editAndDeleteActions(
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: onFinish,
            onError: onError
        )
        messageActions.append(contentsOf: editAndDeleteActions)

        return messageActions
    }

    private static func editAndDeleteActions(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        var messageActions = [MessageAction]()

        let editAction = editMessageAction(
            for: message,
            channel: channel,
            onFinish: onFinish
        )
        messageActions.append(editAction)

        let deleteAction = deleteAction(
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: onFinish,
            onError: onError
        )

        messageActions.append(deleteAction)

        return messageActions
    }
}


// MARK: Threads

extension NSNotification.Name {
    static let selectedMessageThread = NSNotification.Name(MessageRepliesConstants.selectedMessageThread)
    static let selectedMessage = NSNotification.Name(MessageRepliesConstants.selectedMessage)
}

enum MessageRepliesConstants {
    static let selectedMessageThread = "selectedMessageThread"
    static let selectedMessage = "selectedMessage"
}

extension MessageAction {

    static func threadReplyAction<Factory: ViewFactory>(
        factory: Factory,
        for message: ChatMessage,
        channel: ChatChannel
    ) -> MessageAction {
        let replyThread = MessageAction(
            id: MessageActionId.threadReply,
            title: tr("message.actions.thread-reply"),
            iconName: "icn_thread_reply",
            action: {
                NotificationCenter.default.post(
                    name: .selectedMessageThread,
                    object: nil,
                    userInfo: [MessageRepliesConstants.selectedMessage: message]
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return replyThread
    }
}
