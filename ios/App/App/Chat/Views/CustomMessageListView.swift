import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomMessageListView<Factory: ViewFactory>: View {

    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors

    private let firstMessageKey = "firstMessage"
    private let lastMessageKey = "lastMessage"

    var factory: Factory
    var channel: ChatChannel
    var messages: LazyCachedMapCollection<ChatMessage>
    var messagesGroupingInfo: [String: [String]]
    var width: CGFloat?
    var listId: String
    var isMessageThread: Bool
    var onMessageAppear: (Int, ScrollDirection) -> Void
    var onLongPress: (MessageDisplayInfo) -> Void

    @Binding var firstUnreadMessageId: MessageId?
    @Binding var quotedMessage: ChatMessage?
    @Binding var scrolledId: String?
    @Binding var keyboardShown: Bool
    @Binding var scrollDirection: ScrollDirection
    @Binding var unreadMessagesBannerShown: Bool

    public init(
        factory: Factory,
        channel: ChatChannel,
        messages: LazyCachedMapCollection<ChatMessage>,
        messagesGroupingInfo: [String: [String]],
        width: CGFloat?,
        listId: String,
        isMessageThread: Bool,
        onMessageAppear: @escaping (Int, ScrollDirection) -> Void,
        onLongPress: @escaping (MessageDisplayInfo) -> Void,
        firstUnreadMessageId: Binding<MessageId?> = .constant(nil),
        quotedMessage: Binding<ChatMessage?>,
        scrolledId: Binding<String?>,
        keyboardShown: Binding<Bool>,
        scrollDirection: Binding<ScrollDirection>,
        unreadMessagesBannerShown: Binding<Bool>
    ) {
        self.factory = factory
        self.channel = channel
        self.messages = messages
        self.messagesGroupingInfo = messagesGroupingInfo
        self.width = width
        self.listId = listId
        self.isMessageThread = isMessageThread
        self.onMessageAppear = onMessageAppear
        self.onLongPress = onLongPress
        _scrolledId = scrolledId
        _quotedMessage = quotedMessage
        _firstUnreadMessageId = firstUnreadMessageId
        _keyboardShown = keyboardShown
        _scrollDirection = scrollDirection
        _unreadMessagesBannerShown = unreadMessagesBannerShown
    }

    private var messageListDateUtils: CustomMessageListDateUtils {
        CustomMessageListDateUtils(messageListConfig: customMessageListConfig)
    }

    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }

    private var lastInGroupHeaderSize: CGFloat {
        messageListConfig.messageDisplayOptions.lastInGroupHeaderSize
    }

    private var newMessagesSeparatorSize: CGFloat {
        messageListConfig.messageDisplayOptions.newMessagesSeparatorSize
    }

    private func showsLastInGroupInfo(
        for message: ChatMessage,
        channel: ChatChannel
    ) -> Bool {
        guard channel.memberCount > 2
            && !message.isSentByCurrentUser
            && (lastInGroupHeaderSize > 0) else {
            return false
        }
        let groupInfo = messagesGroupingInfo[message.id] ?? []
        return groupInfo.contains(lastMessageKey) == true
    }

    private func additionalTopPadding(showsLastInGroupInfo: Bool, showUnreadSeparator: Bool) -> CGFloat {
        var padding = showsLastInGroupInfo ? lastInGroupHeaderSize : 0
        if showUnreadSeparator {
            padding += newMessagesSeparatorSize
        }
        return padding
    }

    private func offsetForDateIndicator(showsLastInGroupInfo: Bool, showUnreadSeparator: Bool) -> CGFloat {
        var offset = messageListConfig.messageDisplayOptions.dateLabelSize
        offset += additionalTopPadding(showsLastInGroupInfo: showsLastInGroupInfo, showUnreadSeparator: showUnreadSeparator)
        return offset
    }

    private func newMessagesCount(for index: Int?, message: ChatMessage) -> Int {
        channel.unreadCount.messages
    }

    private func showsAllData(for message: ChatMessage) -> Bool {
        if !messageListConfig.groupMessages {
            return true
        }
        let groupInfo = messagesGroupingInfo[message.id] ?? []
        return groupInfo.contains(firstMessageKey) == true
    }

    private func handleLongPress(messageDisplayInfo: MessageDisplayInfo) {
        if keyboardShown {
            resignFirstResponder()
            let updatedFrame = CGRect(
                x: messageDisplayInfo.frame.origin.x,
                y: messageDisplayInfo.frame.origin.y,
                width: messageDisplayInfo.frame.width,
                height: messageDisplayInfo.frame.height
            )

            let updatedDisplayInfo = MessageDisplayInfo(
                message: messageDisplayInfo.message,
                frame: updatedFrame,
                contentWidth: messageDisplayInfo.contentWidth,
                isFirst: messageDisplayInfo.isFirst,
                keyboardWasShown: true
            )

            onLongPress(updatedDisplayInfo)
        } else {
            onLongPress(messageDisplayInfo)
        }
    }

    public var body: some View {
        ForEach(messages, id: \.id) { message in
            var index: Int? = messageListDateUtils.indexForMessageDate(message: message, in: messages)
            let messageDate: Date? = messageListDateUtils.showMessageDate(for: index, in: messages)
            let messageIsFirstUnread = firstUnreadMessageId?.contains(message.id) == true
            let showUnreadSeparator = customMessageListConfig.showNewMessagesSeparator &&
            messageIsFirstUnread &&
            !isMessageThread
            let showsLastInGroupInfo = showsLastInGroupInfo(for: message, channel: channel)
            factory.makeMessageContainerView(
                channel: channel,
                message: message,
                width: width,
                showsAllInfo: showsAllData(for: message),
                isInThread: isMessageThread,
                scrolledId: $scrolledId,
                quotedMessage: $quotedMessage,
                onLongPress: handleLongPress(messageDisplayInfo:),
                isLast: !showsLastInGroupInfo && message == messages.last
            )
            .onAppear {
                if index == nil {
                    index = messageListDateUtils.index(for: message, in: messages)
                }
                if let index = index {
                    onMessageAppear(index, scrollDirection)
                }
            }
            .padding(
                .top,
                messageDate != nil ?
                offsetForDateIndicator(
                    showsLastInGroupInfo: showsLastInGroupInfo,
                    showUnreadSeparator: showUnreadSeparator
                ) :
                    additionalTopPadding(
                        showsLastInGroupInfo: showsLastInGroupInfo,
                        showUnreadSeparator: showUnreadSeparator
                    )
            )
            .overlay(
                (messageDate != nil || showsLastInGroupInfo || showUnreadSeparator) ?
                VStack(spacing: 0) {
                    messageDate != nil ?
                    factory.makeMessageListDateIndicator(date: messageDate!)
                        .frame(maxHeight: messageListConfig.messageDisplayOptions.dateLabelSize)
                    : nil

                    showUnreadSeparator ?
                    factory.makeNewMessagesIndicatorView(
                        newMessagesStartId: $firstUnreadMessageId,
                        count: newMessagesCount(for: index, message: message)
                    )
                    .onAppear {
                        unreadMessagesBannerShown = true
                    }
                    .onDisappear {
                        unreadMessagesBannerShown = false
                    }
                    : nil

                    showsLastInGroupInfo ?
                    factory.makeLastInGroupHeaderView(for: message)
                        .frame(maxHeight: lastInGroupHeaderSize)
                    : nil

                    Spacer()
                }
                : nil
            )
            .flippedUpsideDown()
            .animation(nil, value: messageDate != nil)
        }
        .id(listId)
    }
}
