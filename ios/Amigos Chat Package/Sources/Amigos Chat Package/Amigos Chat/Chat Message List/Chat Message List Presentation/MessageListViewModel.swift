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

    var pollControllerBuilder: PollControllerBuilder?

    let isInThread: Bool

    init(
        reactionsForMessage: Message? = nil,
        messageList: [Message],
        unreadMessagesCount: Int = 0,
        messagesGroupingInfo: [String: [String]] = [:],
        isDirectMessageChat: Bool,
        firstUnreadMessageId: String?,
        isReadHandler: HasSeenHandler,
        isReadByAllHandler: @escaping IsReadByAllHandler = {_ in false},
        config: MessageListDisplayConfiguration,
        isInThread: Bool = false,
        pollControllerBuilder: PollControllerBuilder? = nil
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
        self.isInThread = isInThread
        self.pollControllerBuilder = pollControllerBuilder
    }

    func viewData(
        for message: Message
    ) -> MessageContainerViewModel {

       let viewModel = MessageContainerViewModel(
            message: message,
            showsAllInfo: showsAllData(for: message),
            messagePosition: messagePosition,
            isDirectMessageChat: isDirectMessageChat,
            isRead: isReadHandler.hasSeen(for: message),
            isInThread: isInThread,
            isReadByAllHandler: isReadByAllHandler
        )

        // build pollcontroller if message contains a poll
        if let poll = message.poll {
            viewModel.pollController = pollControllerBuilder?(message.id, poll.id)
        }

        return viewModel
    }

    func showUnreadMessageSeparator(for message: Message) -> Bool {
        messageListConfig.showUnreadSeparator &&
        unreadMessagesCount > 0 &&
        firstUnreadMessageId == message.id
    }

    func showsLastGroupInfo(showUnreadMessages: Bool) -> Bool {
        guard let message = messageList.last,
            !isDirectMessageChat &&
            !message.isSentByCurrentUser
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
        message == messageList.last ? dateLabelOffset() : 0
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

    private func dateLabelOffset() -> CGFloat {
        return messageListConfig.messageDisplayOptions.dateLabelSize
    }

    private func showNameForMessageGroup(message: Message) -> Bool {
         let groupInfo = messagesGroupingInfo[message.id] ?? []
         return groupInfo.contains(lastMessageKey)
     }

    var messagePosition: (Message) -> MessagePosition {

        return { [weak self] message in
            guard let self = self else { return .alone }

            if self.messageList.count == 1 {
                return .alone
            }

            // no grouping info available
            guard let group = self.messagesGroupingInfo[message.id] else {
                return .middle
            }

            let isFirst = group.contains(self.firstMessageKey)
            let isLast = group.contains(self.lastMessageKey)

            if isFirst && isLast {
                return .alone
            } else if isLast {
                /// last message = top message as the list view UI logic is reverted
                return .top
            } else if isFirst {
                /// first message = bottom message as the list view UI logic is reverted
                return .bottom
            } else {
                return .middle
            }
        }
    }
}
