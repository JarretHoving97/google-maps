import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomMessageListContainerView<Factory: ViewFactory>: View, KeyboardReadable {

    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors

    private let scrollAreaId = "scrollArea"
    private let unknownMessageId = "unknown"

    var factory: Factory
    var channel: ChatChannel
    var messages: LazyCachedMapCollection<ChatMessage>
    var messagesGroupingInfo: [String: [String]]
    @Binding var scrolledId: String?
    @Binding var showScrollToLatestButton: Bool
    @Binding var quotedMessage: ChatMessage?
    @Binding var scrollPosition: String?
    @Binding var firstUnreadMessageId: MessageId?
    var loadingNextMessages: Bool
    var currentDateString: String?
    var listId: String
    var isMessageThread: Bool
    var shouldShowTypingIndicator: Bool

    var onMessageAppear: (Int, ScrollDirection) -> Void
    var onScrollToBottom: () -> Void
    var onLongPress: (MessageDisplayInfo) -> Void
    var onJumpToMessage: ((String) -> Bool)?

    @State private var width: CGFloat?
    @State private var keyboardShown = false
    @State private var pendingKeyboardUpdate: Bool?
    @State private var scrollDirection = ScrollDirection.up
    @State private var unreadMessagesBannerShown = false

    private var messageRenderingUtil = MessageRenderingUtil.shared
    private var skipRenderingMessageIds = [String]()

    private var dateFormatter: DateFormatter {
        utils.dateFormatter
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

    public init(
        factory: Factory,
        channel: ChatChannel,
        messages: LazyCachedMapCollection<ChatMessage>,
        messagesGroupingInfo: [String: [String]],
        scrolledId: Binding<String?>,
        showScrollToLatestButton: Binding<Bool>,
        quotedMessage: Binding<ChatMessage?>,
        currentDateString: String? = nil,
        listId: String,
        isMessageThread: Bool = false,
        shouldShowTypingIndicator: Bool = false,
        scrollPosition: Binding<String?> = .constant(nil),
        loadingNextMessages: Bool = false,
        firstUnreadMessageId: Binding<MessageId?> = .constant(nil),
        onMessageAppear: @escaping (Int, ScrollDirection) -> Void,
        onScrollToBottom: @escaping () -> Void,
        onLongPress: @escaping (MessageDisplayInfo) -> Void,
        onJumpToMessage: ((String) -> Bool)? = nil
    ) {
        self.factory = factory
        self.channel = channel
        self.messages = messages
        self.messagesGroupingInfo = messagesGroupingInfo
        self.currentDateString = currentDateString
        self.listId = listId
        self.isMessageThread = isMessageThread
        self.onMessageAppear = onMessageAppear
        self.onScrollToBottom = onScrollToBottom
        self.onLongPress = onLongPress
        self.onJumpToMessage = onJumpToMessage
        self.shouldShowTypingIndicator = shouldShowTypingIndicator
        self.loadingNextMessages = loadingNextMessages
        _scrolledId = scrolledId
        _showScrollToLatestButton = showScrollToLatestButton
        _quotedMessage = quotedMessage
        _scrollPosition = scrollPosition
        _firstUnreadMessageId = firstUnreadMessageId
        if !messageRenderingUtil.hasPreviousMessageSet
            || self.showScrollToLatestButton == false
            || self.scrolledId != nil
            || messages.first?.isSentByCurrentUser == true {
            messageRenderingUtil.update(previousTopMessage: messages.first)
        }
        skipRenderingMessageIds = messageRenderingUtil.messagesToSkipRendering(newMessages: messages)
        if !skipRenderingMessageIds.isEmpty {
            self.messages = LazyCachedMapCollection(
                source: messages.filter { !skipRenderingMessageIds.contains($0.id) },
                map: { $0 }
            )
        }
    }

    private var messageCachingUtils = CustomMessageCachingUtils()

    public var body: some View {
        ZStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    GeometryReader { proxy in
                        let frame = proxy.frame(in: .named(scrollAreaId))
                        let offset = frame.minY
                        let width = frame.width
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        Color.clear.preference(key: WidthPreferenceKey.self, value: width)
                    }
                    LazyVStack(spacing: 0, pinnedViews: .sectionFooters) {
                        Section {
                            CustomMessageListView(
                                factory: factory,
                                channel: channel,
                                messages: messages,
                                messagesGroupingInfo: messagesGroupingInfo,
                                width: width,
                                listId: listId,
                                isMessageThread: isMessageThread,
                                onMessageAppear: onMessageAppear,
                                onLongPress: onLongPress,
                                firstUnreadMessageId: $firstUnreadMessageId,
                                quotedMessage: $quotedMessage,
                                scrolledId: $scrolledId,
                                keyboardShown: $keyboardShown,
                                scrollDirection: $scrollDirection,
                                unreadMessagesBannerShown: $unreadMessagesBannerShown
                            )
                        }
                    }
                    .modifier(factory.makeMessageListModifier())
                    .modifier(ScrollTargetLayoutModifier(enabled: loadingNextMessages))
                }
                .modifier(ScrollPositionModifier(scrollPosition: loadingNextMessages ? $scrollPosition : .constant(nil)))
                .background(
                    factory.makeMessageListBackground(
                        colors: colors,
                        isInThread: isMessageThread
                    )
                )
                .coordinateSpace(name: scrollAreaId)
                .onPreferenceChange(WidthPreferenceKey.self) { value in
                    if let value = value, value != width {
                        self.width = value
                    }
                }
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    DispatchQueue.main.async {
                        let offsetValue = value ?? 0
                        let diff = offsetValue - messageCachingUtils.scrollOffset
                        if abs(diff) > 15 {
                            if diff > 0 {
                                if scrollDirection == .up {
                                    scrollDirection = .down
                                }
                            } else if diff < 0 && scrollDirection == .down {
                                scrollDirection = .up
                            }
                        }
                        messageCachingUtils.scrollOffset = offsetValue
                        let scrollButtonShown = offsetValue < -20
                        if scrollButtonShown != showScrollToLatestButton {
                            showScrollToLatestButton = scrollButtonShown
                        }
                        if keyboardShown && diff < -20 {
                            keyboardShown = false
                            resignFirstResponder()
                        }
                        if offsetValue > 5 {
                            onMessageAppear(0, .down)
                        }
                    }
                }
                .flippedUpsideDown()
                .frame(maxWidth: .infinity)
                .clipped()
                .onChange(of: scrolledId) { scrolledId in
                    if let scrolledId = scrolledId {
                        let shouldJump = onJumpToMessage?(scrolledId) ?? false
                        if !shouldJump {
                            return
                        }
                        withAnimation {
                            scrollView.scrollTo(scrolledId, anchor: messageListConfig.scrollingAnchor)
                        }
                    }
                }
                .accessibilityIdentifier("MessageListScrollView")
            }

            CustomMessageContainerHeaderView(channel: channel)
                .frame(
                    maxHeight: .infinity,
                    alignment: Alignment(horizontal: .center, vertical: .top)
                )

            if showScrollToLatestButton {
                factory.makeScrollToBottomButton(
                    unreadCount: channel.unreadCount.messages,
                    onScrollToBottom: onScrollToBottom
                )
            }

            if shouldShowTypingIndicator {
                factory.makeTypingIndicatorBottomView(
                    channel: channel,
                    currentUserId: chatClient.currentUserId
                )
            }
        }
        .onReceive(keyboardDidChangePublisher) { visible in
            if currentDateString != nil {
                pendingKeyboardUpdate = visible
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    keyboardShown = visible
                }
            }
        }
        .onChange(of: currentDateString, perform: { dateString in
            if dateString == nil, let keyboardUpdate = pendingKeyboardUpdate {
                keyboardShown = keyboardUpdate
                pendingKeyboardUpdate = nil
            }
        })
        .onTapGesture {
            resignFirstResponder()
        }
        .overlay(
            (channel.unreadCount.messages > 0 && !unreadMessagesBannerShown && !isMessageThread) ?
                factory.makeJumpToUnreadButton(
                    channel: channel,
                    onJumpToMessage: {
                        _ = onJumpToMessage?(firstUnreadMessageId ?? unknownMessageId)
                    },
                    onClose: {
                        firstUnreadMessageId = nil
                    }
                ) : nil
        )
        .modifier(factory.makeMessageListContainerModifier())
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
        .onDisappear {
            messageRenderingUtil.update(previousTopMessage: nil)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageListView")
    }
}

struct ScrollPositionModifier: ViewModifier {
    @Binding var scrollPosition: String?

    func body(content: Content) -> some View {
        #if swift(>=5.9)
        if #available(iOS 17, *) {
            content
                .scrollPosition(id: $scrollPosition, anchor: .top)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

struct ScrollTargetLayoutModifier: ViewModifier {

    var enabled: Bool

    func body(content: Content) -> some View {
        if !enabled {
            return content
        }
        #if swift(>=5.9)
        if #available(iOS 17, *) {
            return content
                .scrollTargetLayout(isEnabled: enabled)
                .scrollTargetBehavior(.paging)
        } else {
            return content
        }
        #else
        return content
        #endif
    }
}

public struct CustomNewMessagesIndicatorView: View {

    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    @Binding var newMessagesStartId: String?
    var count: Int

    public init(newMessagesStartId: Binding<String?>, count: Int) {
        _newMessagesStartId = newMessagesStartId
        self.count = count
    }

    var line: some View {
        VStack {
            Divider()
                .background(Color("Purple"))
        }
     }

    public var body: some View {
        HStack(spacing: 20) {
            line

            Text(tr("custom.newMessagesIndicator.title", count))
                .fixedSize()
                .font(fonts.subheadline)
                .foregroundColor(Color("Purple"))

            line
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 12)
    }
}

public struct CustomScrollToBottomButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    private let buttonSize: CGFloat = 32

    var unreadCount: Int
    var onScrollToBottom: () -> Void

    public var body: some View {
        BottomRightView {
            Button {
                onScrollToBottom()
            } label: {
                Image(uiImage: images.scrollDownArrow)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(.white)
                    .clipShape(Circle())
                    .modifier(ShadowModifier())
            }
            .padding(8)
        }
        .accessibilityIdentifier("ScrollToBottomButton")
    }
}

struct CustomUnreadButtonIndicator: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    private let size: CGFloat = 16

    var unreadCount: Int

    var body: some View {
        Text("\(unreadCount)")
            .lineLimit(1)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .font(fonts.footnoteBold)
            .frame(width: unreadCount < 10 ? size : nil, height: size)
            .padding(.horizontal, unreadCount < 10 ? 2 : 6)
            .background(Color("Orange"))
            .cornerRadius(9)
            .foregroundColor(Color(colors.staticColorText))
            .offset(y: -size)
    }
}

public struct DateIndicatorView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var dateString: String

    public init(date: Date) {
        dateString = DateFormatter.messageListDateOverlay.string(from: date)
    }

    public init(dateString: String) {
        self.dateString = dateString
    }

    public var body: some View {
        VStack {
            Text(dateString)
                .font(fonts.footnote)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundColor(.white)
                .background(Color(colors.textLowEmphasis))
                .cornerRadius(16)
                .padding(.all, 8)
            Spacer()
        }
    }
}

struct TypingIndicatorBottomView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var typingIndicatorString: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                TypingIndicatorView()
                Text(typingIndicatorString)
                    .font(.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
                Spacer()
            }
            .standardPadding()
            .background(
                Color(colors.background)
                    .opacity(0.9)
            )
            .accessibilityIdentifier("TypingIndicatorBottomView")
        }
        .accessibilityElement(children: .contain)
    }
}

private class MessageRenderingUtil {

    private var previousTopMessage: ChatMessage?

    static let shared = MessageRenderingUtil()

    var hasPreviousMessageSet: Bool {
        previousTopMessage != nil
    }

    func update(previousTopMessage: ChatMessage?) {
        self.previousTopMessage = previousTopMessage
    }

    func messagesToSkipRendering(newMessages: LazyCachedMapCollection<ChatMessage>) -> [String] {
        let newTopMessage = newMessages.first
        if newTopMessage?.id == previousTopMessage?.id {
            return []
        }

        if newTopMessage?.cid != previousTopMessage?.cid {
            previousTopMessage = newTopMessage
            return []
        }

        var skipRendering = [String]()
        for message in newMessages {
            if previousTopMessage?.id == message.id {
                break
            } else {
                skipRendering.append(message.id)
            }
        }

        return skipRendering
    }
}

struct CustomMessageContainerHeaderView: View {

    let channel: ChatChannel

    public init(channel: ChatChannel) {
        self.channel = channel
    }

    var body: some View {
        VStack {
            if channel.isDirectMessageChannel {
                CustomSafetyCheckNotice(channel: channel)

                CustomChatSuperPowerOnlyNoticeView(channel: channel)
            } else {
                CustomPinnedMessage(channel: channel)
            }
        }
    }
}
