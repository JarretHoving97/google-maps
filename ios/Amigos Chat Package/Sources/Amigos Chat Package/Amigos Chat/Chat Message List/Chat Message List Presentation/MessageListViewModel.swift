//
//  Untitled.swift
//  Amigos Chat Package
//
//  Created by Jarret on 09/05/2025.
//

import Foundation

@MainActor
class MessageListViewModel: ObservableObject {

    @Published var reactionsForMessage: Message?

    @Published private(set) var messageList = [Message]()

    let unreadMessagesCount: Int

    let messageListConfig: MessageListDisplayConfiguration

    var messagesGroupingInfo: [String: [String]]

    let isDirectMessageChat: Bool

    let firstUnreadMessageId: String?

    private let firstMessageKey = "firstMessage"
    private let lastMessageKey = "lastMessage"

    let isReadHandler: HasSeenHandler

    let isReadByAllHandler: IsReadByAllHandler

    init(
        reactionsForMessage: Message? = nil,
        messageList: [Message],
        unreadMessagesCount: Int = 0,
        messagesGroupingInfo: [String: [String]] = [:],
        isDirectMessageChat: Bool,
        firstUnreadMessageId: String?,
        isReadHandler: HasSeenHandler,
        isReadByAllHandler: @escaping IsReadByAllHandler = {_ in false},
        config: MessageListDisplayConfiguration
    ) {
        self.reactionsForMessage = reactionsForMessage
        self.messageList = messageList
        self.messagesGroupingInfo = messagesGroupingInfo
        self.isDirectMessageChat = isDirectMessageChat
        self.messageListConfig = config
        self.firstUnreadMessageId = firstUnreadMessageId
        self.unreadMessagesCount = unreadMessagesCount
        self.isReadHandler = isReadHandler
        self.isReadByAllHandler = isReadByAllHandler
    }

    func viewData(
        for message: Message
    ) -> MessageContainerViewModel {

        MessageContainerViewModel(
            message: message,
            showsAllInfo: showsAllData(for: message),
            isLast: isLastMessage(message),
            isDirectMessageChat: isDirectMessageChat,
            isRead: isReadHandler.hasSeen(for: message),
            isReadByAllHandler: isReadByAllHandler
        )
    }

    func showUnreadMessageSeparator(for message: Message) -> Bool {
        messageListConfig.showUnreadSeparator &&
        firstUnreadMessageId?.contains(message.id) == true
    }

    func showsLastGroupInfo(showUnreadMessages: Bool) -> Bool {
        guard let message = messageList.last,
            !isDirectMessageChat &&
            !message.isSentByCurrentUser &&
            lastGroupHeaderSize(showUnreadMessages: showUnreadMessages) > 0
        else { return false }

        let groupInfo = messagesGroupingInfo[message.id] ?? []
        return groupInfo.contains(lastMessageKey)
    }

    func showMessageDate(
        for index: Int?
    ) -> Date? {
        guard let index = index else {
            return nil
        }

        let message = messageList[index]
        let previousIndex = index + 1
        if previousIndex < messageList.count {
            let previous = messageList[previousIndex]
            return messageListConfig
                .messageDisplayOptions
                .messageDateSeparator(message, previous)
        } else {
            return message.createdAt
        }
    }

    func padding(for message: Message) -> CGFloat {

        let showUnreadSeparator = showUnreadMessageSeparator(for: message)

        if message == messageList.last {
            return dateLabelOffset(showUnreadMessages: showUnreadSeparator)

        } else {
            return lastGroupHeaderSize(showUnreadMessages: showUnreadSeparator)
        }
    }

    func indexForMessageDate(
        message: Message
    ) -> Int? {
        messageListConfig.indexForMessageDate(message: message, in: messageList)
    }

    func newMessageViewData(for message: Message) -> NewMessageIndicatorViewModel {
        NewMessageIndicatorViewModel(
            newMessageStartId: message.id,
            show: showUnreadMessageSeparator(for: message),
            count: unreadMessagesCount
        )
    }

    private func showsAllData(for message: Message) -> Bool {
        let groupInfo = messagesGroupingInfo[message.id] ?? []
        return groupInfo.contains(firstMessageKey)
    }

    private func isLastMessage(_ message: Message) -> Bool {
        return message == messageList.last
    }

   private func lastGroupHeaderSize(showUnreadMessages: Bool) -> CGFloat {

        var padding: CGFloat = 0

        padding = showUnreadMessages ? padding + 50 : padding

        return padding
    }

    private func dateLabelOffset(showUnreadMessages: Bool) -> CGFloat {
        var offset = messageListConfig.messageDisplayOptions.dateLabelSize
        offset = showUnreadMessages ? offset + 50 : offset

        return offset
    }
}
