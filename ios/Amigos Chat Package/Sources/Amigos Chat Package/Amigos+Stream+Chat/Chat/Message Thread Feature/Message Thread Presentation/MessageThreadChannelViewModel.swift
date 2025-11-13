//
//  MessageThreadChannelViewData.swift
//  Amigos Chat Package
//
//  Created by Jarret on 09/10/2025.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

public class MessageThreadChannelViewModel: ObservableObject {

    @Injected(\.utils) var utils

    private(set) var messageController: ChatMessageController

    private(set) var channelController: ChatChannelController

    let pollControllerbuilder: PollControllerBuilder?

    @MainActor
    var repliedMessagePollController: PollControllerProtocol? {
        guard let messageId = repliedMessage?.id, let pollId = repliedMessage?.poll?.id else { return nil }

        return pollControllerbuilder?(messageId, pollId)
    }

    var channel: ChatChannel? {
        return channelController.channel
    }

    let navigationTitle: String

    @MainActor
    var repliedMessage: ChatMessage? {
        return messageController.repliedMessage
    }

    @MainActor
    var messages: [ChatMessage] {
        return Array(messageController.replies)
    }

    @MainActor
    var allMesages: [ChatMessage] {
        [repliedMessage].compactMap { $0 } + messages
    }

    @Published
    var messageReactionPresentationInfo: MessageReactionsInfo?

    private let firstMessageKey = "firstMessage"
    private let lastMessageKey = "lastMessage"

    init(
        messageController: ChatMessageController,
        channelController: ChatChannelController,
        pollControllerbuilder: PollControllerBuilder?,
        navigationTitle: String,
    ) {
        self.messageController = messageController
        self.channelController = channelController
        self.navigationTitle = navigationTitle
        self.pollControllerbuilder = pollControllerbuilder
    }
}
