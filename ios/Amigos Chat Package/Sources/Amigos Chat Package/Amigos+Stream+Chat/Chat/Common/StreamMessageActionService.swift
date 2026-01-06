//
//  StreamMessageActionService.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/11/2025.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import UIKit.UIPasteboard

struct StreamMessageActionService {

    public enum MessageActionId {
        public static let copy = "copy_message_action"
        public static let reply = "reply_message_action"
        public static let threadReply = "thread_message_action"
        public static let edit = "edit_message_action"
        public static let delete = "delete_message_action"
        public static let mute = "mute_message_action"
        public static let unmute = "unmute_message_action"
        public static let flag = "flag_message_action"
        public static let pin = "pin_message_action"
        public static let unpin = "unpin_message_action"
        public static let resend = "resend_message_action"
        public static let markUnread = "mark_unread_action"
        public static let block = "block_user_action"
        public static let unblock = "unblock_user_action"
        public static let replyPrivately = "reply_privately"
    }

    private let chatClient: ChatClient

    private let channelController: ChatChannelController

    private let message: ChatMessage

    private let isInThread: Bool

    private let router: Router?

    private let channelCreationService: ChannelCreationService

    init(
        chatClient: ChatClient,
        router: Router? = InjectedValues[\.chatRouter],
        channelCreationService: ChannelCreationService = RemoteFindOrCreateChannelService(),
        channelController: ChatChannelController,
        isInThread: Bool,
        message: ChatMessage
    ) {
        self.chatClient = chatClient
        self.channelController = channelController
        self.isInThread = isInThread
        self.message = message
        self.router = router
        self.channelCreationService = channelCreationService
    }
}

// MARK: Protocol
extension StreamMessageActionService: MessageActionService {

    func createMessageActions(
        on actionCallback: @escaping MessageActionCompletion
    ) -> [CustomMessageAction] {

        guard let channelId = message.cid, let channel = chatClient.channelController(for: channelId).channel else {
            // Fallback to minimal actions if channel cannot be resolved
            var actions: [CustomMessageAction] = []
            if !message.text.isEmpty {
                actions.append(copyAction(on: actionCallback))
            }
            if !isInThread {
                actions.append(threadReplyAction(on: actionCallback))
            }
            return actions
        }

        // Failed send
        if message.localState == .sendingFailed {
            return [
                resendAction(channel: channel, on: actionCallback),
                editAction(on: actionCallback),
                deleteAction(channel: channel, on: actionCallback)
            ]
        }

        // Pending send with failed attachment upload
        if message.localState == .pendingSend && message.allAttachments.contains(where: { $0.uploadingState?.state == .uploadingFailed }) {
            return [
                editAction(on: actionCallback),
                deleteAction(channel: channel, on: actionCallback)
            ]
        }

        if message.isBounced {
            var bounced = [CustomMessageAction]()
            let title = CustomMessageAction(
                id: "bounce_title",
                title: tr("message.bounce.title"),
                iconName: "",
                action: {},
                confirmationPopup: nil,
                isDestructive: false
            )
            bounced.append(resendAction(channel: channel, on: actionCallback))
            bounced.append(editAction(on: actionCallback))
            bounced.append(deleteAction(channel: channel, on: actionCallback))
            return [title] + bounced
        }

        var actions: [CustomMessageAction] = []

        if channel.canQuoteMessage {
            actions.append(inlineReplyAction(on: actionCallback))
        }

        if channel.isCommunityChannel && !message.isSentByCurrentUser && !isInThread {
            actions.append(replyPrivately(on: actionCallback))
        }

        if channel.config.repliesEnabled && !isInThread {
            actions.append(threadReplyAction(on: actionCallback))
        }

        if !message.text.isEmpty {
            actions.append(copyAction(on: actionCallback))
        }

        let isOwnMessageMutable = abs(message.createdAt.timeIntervalSinceNow) <= TimeInterval(60 * 15)

        if channel.ownCapabilities.contains(.updateOwnMessage) && message.isSentByCurrentUser && isOwnMessageMutable {
            if message.poll == nil {
                actions.append(editAction(on: actionCallback))
            }
        }

        let isOwnMessageDeletable = channel.ownCapabilities.contains(.deleteOwnMessage) && message.isSentByCurrentUser && isOwnMessageMutable
        let isAnyMessageDeletable = channel.ownCapabilities.contains(.deleteAnyMessage)

        if isOwnMessageDeletable || isAnyMessageDeletable {
            actions.append(deleteAction(channel: channel, on: actionCallback))
        }

        if !message.isSentByCurrentUser && (!message.isPartOfThread || message.showReplyInChannel) {
            actions.append(markUnreadAction(channel: channel, on: actionCallback))
        }

        return actions
    }
}

// MARK: methods
extension StreamMessageActionService {

    private func copyAction(on actionCallback: @escaping MessageActionCompletion) -> CustomMessageAction {
        CustomMessageAction(
            id: MessageActionId.copy,
            title: tr("message.actions.copy"),
            iconName: "",
            action: {
                UIPasteboard.general.string = message.adjustedText
                actionCallback(.success(CustomMessageActionInfo(message: message, identifier: MessageActionId.copy)))
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    private func editAction(on actionCallback: @escaping MessageActionCompletion) -> CustomMessageAction {
        CustomMessageAction(
            id: MessageActionId.edit,
            title: tr("message.actions.edit"),
            iconName: "",
            action: {
                actionCallback(.success(CustomMessageActionInfo(message: message, identifier: MessageActionId.edit)))
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    private func inlineReplyAction(on actionCallback: @escaping MessageActionCompletion) -> CustomMessageAction {
        CustomMessageAction(
            id: MessageActionId.reply,
            title: tr("message.actions.inline-reply"),
            iconName: "",
            action: {
                actionCallback(.success(CustomMessageActionInfo(message: message, identifier: "inlineReply")))
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    private func deleteAction(
        channel: ChatChannel,
        on actionCallback: @escaping MessageActionCompletion
    ) -> CustomMessageAction {
        CustomMessageAction(
            id: MessageActionId.delete,
            title: tr("message.actions.delete"),
            iconName: "",
            action: {
                let controller = chatClient.messageController(cid: channel.cid, messageId: message.id)
                controller.deleteMessage { error in
                    if let error {
                        actionCallback(.failure(error))
                    } else {
                        actionCallback(.success(CustomMessageActionInfo(message: message, identifier: MessageActionId.delete)))
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: true
        )
    }

    private func markUnreadAction(
        channel: ChatChannel,
        on actionCallback: @escaping MessageActionCompletion
    ) -> CustomMessageAction {
        CustomMessageAction(
            id: MessageActionId.markUnread,
            title: tr("message.actions.mark-unread"),
            iconName: "",
            action: {
                channelController.markUnread(from: message.id) { result in
                    switch result {
                    case .success:
                        actionCallback(.success(CustomMessageActionInfo(message: message, identifier: MessageActionId.markUnread)))
                    case .failure(let error):
                        actionCallback(.failure(error))
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    private func resendAction(
        channel: ChatChannel,
        on actionCallback: @escaping MessageActionCompletion
    ) -> CustomMessageAction {
        CustomMessageAction(
            id: MessageActionId.resend,
            title: tr("message.actions.resend"),
            iconName: "",
            action: {
                let controller = chatClient.messageController(cid: channel.cid, messageId: message.id)
                controller.resendMessage { error in
                    if let error {
                        actionCallback(.failure(error))
                    } else {
                        actionCallback(.success(CustomMessageActionInfo(message: message, identifier: MessageActionId.resend)))
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    func threadReplyAction(on actionCallback: @escaping MessageActionCompletion) -> CustomMessageAction {
        return CustomMessageAction(
            id: MessageActionId.threadReply,
            title: tr("message.actions.thread-reply"),
            iconName: "icn_thread_reply",
            action: {

                // dismiss first
                actionCallback(.success(CustomMessageActionInfo(message: message, identifier: MessageActionId.threadReply)))

                // perform navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    Task { @MainActor in
                        router?.push(.thread(MessageThreadChannelViewData(channelId: message.channelId, messageId: message.id)))
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    func replyPrivately(on actionCallback: @escaping MessageActionCompletion) -> CustomMessageAction {

        return CustomMessageAction(
            id: MessageActionId.replyPrivately,
            title: Localized.ChatChannel.replyPrivatelyMessageAction,
            iconName: "",
            action: {
                // dismiss first
                actionCallback(
                    .success(
                        CustomMessageActionInfo(message: message, identifier: MessageActionId.replyPrivately)
                    )
                )

                // perform navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    Task { @MainActor in
                        let channel = try await channelCreationService.load(for: message.user.userId)
                        router?.push(.conversation(.channelInfo(ChannelInfo(messageId: message.id, channelId: channel))))
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }
}
