//
//  MessageThreadChannelView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 06/10/2025.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI
import Combine

struct MessageThreadChannelView: View, KeyboardReadable {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: MessageThreadChannelViewModel

    @StateObject private var channelViewModel: ChatChannelViewModel

    @State private var scrollDirection = MessageListView.ScrollDirection.up

    @State private var reactionsShown: Bool = false

    @State private var overlayDisplayInfo: LocalMessageDisplayInfo?

    private var onMoreTapped: onMoreTappedAction?

    private let mapper = MessageMapper()

    let factory = CustomUIFactory()

    // Scrolling parity with CustomMessageListContainerView
    private let scrollAreaId = "scrollArea"

    var onMessageAppear: (Int, ScrollDirection) -> Void {
        channelViewModel.handleMessageAppear(index:scrollDirection:)
    }

    /// used to bridge the onMessageAppear to the stream
    private var extendedOnMessageAppear: (Int, LocalScrollDirection) -> Void { {onMessageAppear($0, $1.toStream) }}

    @State private var width: CGFloat?
    @State private var keyboardShown = false
    @State private var pendingKeyboardUpdate: Bool?

    private var messageCachingUtils = CustomMessageCachingUtils()

    private var shouldPresentOverlay: Bool {
        overlayDisplayInfo != nil
    }

    init(
        viewModel: MessageThreadChannelViewModel,
        onMoreTapped: onMoreTappedAction? = nil,
        handleMessageAction: @escaping (MessageActionInfo) -> Void = {_ in }
    ) {
        _channelViewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeChannelViewModel(
                with: viewModel.channelController,
                messageController: viewModel.messageController,
                scrollToMessage: nil
            )
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onMoreTapped = onMoreTapped
    }

    var body: some View {
        VStack(spacing: 0) {

            messageRepliesContainer

            Spacer(minLength: 0)

            messageComposerView
        }
        .background(Color(.chatBackground).ignoresSafeArea(.all))
        .sheet(isPresented: $viewModel.messageReactionPresentationInfo.toBoolBinding) {
            reactionsForMessageView(viewInfo: $viewModel.messageReactionPresentationInfo)
        }
        .overlayPresenter(
            isPresented: Binding(
                get: { shouldPresentOverlay },
                set: { newValue in
                    if !newValue {
                        overlayDisplayInfo = nil

                    }
                }
            ),
            transition: .crossDissolve
        ) {
            if let mdi = overlayDisplayInfo, let channel = channelViewModel.channel {
                CustomReactionsOverlayView(
                    factory: factory,
                    channel: channel,
                    messageDisplayInfo: mdi
                ) {
                    withAnimation {
                        overlayDisplayInfo = nil
                    }
                } onActionExecuted: { actionInfo in
                    channelViewModel.messageActionExecuted(actionInfo)
                    withAnimation {
                        overlayDisplayInfo = nil
                    }
                }

            } else {
                Color.clear.ignoresSafeArea()
            }

        }
        .onReceive(keyboardDidChangePublisher) { visible in
            // No header overlay here; we can apply the same simple logic as the container when keyboard changes.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                keyboardShown = visible
            }
        }
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
        .navigationTitle(viewModel.navigationTitle)
        .tint(Color(.purple))
    }

    private func handleLongPress() -> LongPressHandler {

        let allMessages = viewModel.allMesages

        return { [allMessages] info in
            guard let message = allMessages.first(where: {$0.id == info.id}) else { return }

            overlayDisplayInfo = LocalMessageDisplayInfo(
                message: message,
                frame: info.frame,
                contentWidth: max(240, info.frame.width),
                isFirst: false,
                pollViewData: info.pollViewData
            )
        }
    }

    private func handleMessageReply(messageId: String) {
        if let message = viewModel.allMesages.first(where: { $0.id == messageId }) {
            if channelViewModel.quotedMessage?.id != messageId {
                triggerHapticFeedback(style: .medium)
            }

            channelViewModel.quotedMessage = message
        }
    }

    /// Presents the reactions for the message view.
    @ViewBuilder func reactionsForMessageView(viewInfo: Binding<MessageReactionsInfo?>) -> some View {
        if let message = viewModel.allMesages.first(where: { $0.id == viewModel.messageReactionPresentationInfo!.id }) {
            CustomReactionsUsersSheetView(
                isPresented: $viewModel.messageReactionPresentationInfo.toBoolBinding,
                viewModel: ReactionsOverlayViewModel(
                    message: message
                )
            )
        }
    }
}

// MARK: Views
extension MessageThreadChannelView {

    @ViewBuilder func headerView() -> some View {

        if let message = viewModel.repliedMessage {
            VStack(spacing: 0) {
                HStack {
                    if message.isSentByCurrentUser {
                        Spacer()
                    }
                    MessageContainerView(
                        viewModel: MessageContainerViewModel(
                            message: mapper.map(message),
                            showsAllInfo: true,
                            isLast: true,
                            isDirectMessageChat: true,
                            isRead: false,
                            pollController: viewModel.repliedMessagePollController
                        ),
                        gestureCallbacks: MessageGestureCallbacks(
                            onQuotedMessageTap: { channelViewModel.scrolledId = $0},
                            onMessageReply: handleMessageReply(messageId:),
                            onLongPress: handleLongPress(),
                            onReactionsTap: { viewModel.messageReactionPresentationInfo = $0}
                        ), pollOptionAllVotesViewBuilder: nil, // TBA
                    )
                    if !message.isSentByCurrentUser {
                        Spacer()
                    }
                }
                Spacer()

                Divider()
            }
            .background(Color(.greyLight))
            .flippedUpsideDown()
        }
    }

    @ViewBuilder
    private var messageRepliesContainer: some View {

        ScrollViewReader { scrollProxy in
            ScrollView {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .named(scrollAreaId))
                    let offset = frame.minY
                    let currentWidth = frame.width

                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                    Color.clear.preference(key: WidthPreferenceKey.self, value: currentWidth)
                }

                VStack(spacing: 0) {
                    LazyVStack(spacing: 0) {
                        MessageListView(
                            viewModel: MessageListViewModel(
                                messageList: viewModel.messages.map { mapper.map($0) },
                                messagesGroupingInfo: channelViewModel.messagesGroupingInfo,
                                isDirectMessageChat: false,
                                firstUnreadMessageId: nil,
                                isReadHandler: DefaultsHasSeenHandler(),
                                config: MessageListDisplayConfiguration(),
                                isInThread: true,
                                pollControllerBuilder: viewModel.pollControllerbuilder
                            ),
                            callbacks: MessageGestureCallbacks(
                                onQuotedMessageTap: { channelViewModel.scrolledId = $0},
                                onMessageReply: handleMessageReply(messageId:),
                                onLongPress: handleLongPress(),
                                onReactionsTap: { viewModel.messageReactionPresentationInfo = $0}
                            ),
                            width: width ?? .messageWidth,
                            scrollDirection: $scrollDirection,
                            onMessageAppear: extendedOnMessageAppear,
                            pollOptionAllVotesViewBuilder: nil, // TBA
                        )
                    }
                    headerView()
                }
            }
            .dismissKeyboardAndAttachmentViewOnTap()
            .background(Color(.chatBackground))
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
                    if scrollButtonShown != channelViewModel.showScrollToLatestButton {
                        channelViewModel.showScrollToLatestButton = scrollButtonShown
                    }

                    if keyboardShown && diff < -20 {
                        keyboardShown = false
                        resignFirstResponder()
                    }
                }
            }
            .flippedUpsideDown()
            .frame(maxWidth: .infinity)
            .clipped()
            .onChange(of: channelViewModel.scrolledId) { scrolledId in
                if let scrolledId = scrolledId {
                    let shouldJump = channelViewModel.jumpToMessage(messageId: scrolledId)
                    if !shouldJump {
                        return
                    }
                    withAnimation {
                        scrollProxy.scrollTo(scrolledId, anchor: viewModel.utils.messageListConfig.scrollingAnchor)
                    }
                }
            }
            .accessibilityIdentifier("ThreadMessageListScrollView")
        }
        .overlay(alignment: .bottomTrailing) {
            if channelViewModel.showScrollToLatestButton {
                CustomScrollToBottomButton(
                    unreadCount: 0,
                    onScrollToBottom: {
                        withAnimation {
                            channelViewModel.showScrollToLatestButton = false
                            channelViewModel.scrollToLastMessage()
                        }
                    }
                )
            }
        }
    }

    private var messageComposerView: some View {
        factory.makeMessageComposerViewType(
            with: channelViewModel.channelController,
            messageController: channelViewModel.messageController,
            quotedMessage: $channelViewModel.quotedMessage,
            editedMessage: $channelViewModel.editedMessage,
            onMessageSent: channelViewModel.scrollToLastMessage
        )
    }
}
