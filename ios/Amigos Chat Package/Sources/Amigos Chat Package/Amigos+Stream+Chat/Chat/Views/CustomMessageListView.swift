import StreamChat
import SwiftUI
import StreamChatSwiftUI

class CustomMessageListViewModel: ObservableObject {
    @Published var showReactionsSheet: Bool = false
    @Published var reactionsForMessage: ChatMessage?
}

public struct CustomMessageListView<Factory: ViewFactory>: View {

    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors

    @StateObject private var viewModel = CustomMessageListViewModel()

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

    private func handleLongPress(message: ChatMessage, frame: CGRect) {
        resignFirstResponder()

        let updatedDisplayInfo = MessageDisplayInfo(
            message: message,
            frame: frame,
            contentWidth: frame.width,
            isFirst: showsAllData(for: message),
            keyboardWasShown: true
        )
        onLongPress(updatedDisplayInfo)
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

            var isRead: Bool {
                // Check if the current user has read the message
                let readUsers = channel.readUsers(currentUserId: chatClient.currentUserId, message: message)
                return readUsers.contains(where: { $0.id == chatClient.currentUserId })
            }

            var isReadByAll: Bool {
                // Filter out current user from last active members
                let readUsers = channel.readUsers(currentUserId: chatClient.currentUserId, message: message)
                let memberIds = channel.lastActiveMembers.map(\.id).filter { $0 != message.author.id }
                return memberIds.allSatisfy { memberId in
                    readUsers.contains(where: { $0.id == memberId })
                }
            }

            MessageContainerComposer.compose(
                with: message,
                width: width ?? .messageWidth,
                showsAllinfo: showsAllData(for: message),
                isLast: !showsLastInGroupInfo && message == messages.last,
                isDirectMessageChat: channel.isDirectMessageChannel,
                isRead: isRead,
                isReadByAll: isReadByAll,
                onQuotedMessageTap: { id in scrolledId = id },
                onMessageReply: { quoteMessage(message: message) },
                onReactionsTap: { id in
                    viewModel.reactionsForMessage = messages.first(where: {$0.id == id})
                },
                onLongPress: { frame in
                    handleLongPress(message: message, frame: frame)
                }
            )
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

            .onAppear {

                if index == nil {
                    index = messageListDateUtils.index(for: message, in: messages)
                }
                if let index = index {
                    onMessageAppear(index, scrollDirection)
                }
            }

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
        .sheet(isPresented: $viewModel.reactionsForMessage.toBoolBinding) {
            CustomReactionsUsersSheetView(
                isPresented: $viewModel.reactionsForMessage.toBoolBinding,
                viewModel: ReactionsOverlayViewModel(
                    message:  viewModel.reactionsForMessage!
                )
            )
        }
    }

    private func quoteMessage(message: ChatMessage) {
        // prevents from haptic feedback spamming
        if self.quotedMessage != message {
            triggerHapticFeedback(style: .medium)
        }
        self.quotedMessage = message
    }
}

// MARK: - Temporary extension as we need to get rid of `ChatMessage` in the future`
extension Binding where Value == ChatMessage? {
    var toBoolBinding: Binding<Bool> {
        Binding<Bool>.init {
            self.wrappedValue != nil
        } set: { value in
            if !value {
                self.wrappedValue = nil
            }
        }
    }
}
