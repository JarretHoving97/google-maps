import SwiftUI
import StreamChat
import StreamChatSwiftUI

extension ChatChannelViewModel {

    var canSendMessage: Bool {
        channelController.channel?.canSendMessage ?? true
    }
}

struct CustomChatChannelMessageListView<Factory: ViewFactory>: View {

    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    @StateObject private var viewModel: ChatChannelViewModel

    @Environment(\.presentationMode) var presentationMode

    @State private var messageDisplayInfo: LocalMessageDisplayInfo?
    @State private var tabBarAvailable: Bool = false

    private var factory: Factory

    private let channel: ChatChannel

    private let messageId: String?

    private var onReloadChannelHeader: ((ChatChannel) -> Void)?

    // MARK: Maybe not needed after all
    private let channelControllerBuilder: ChannelControllerBuilder?

    private let messageThreadNavigationAction: MessageThreadNavigationAction

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        onReloadChannelHeader: ((ChatChannel) -> Void)?,
        viewModel: ChatChannelViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        channelControllerBuilder: ChannelControllerBuilder? = nil,
        messageId: String? = nil,
        messageThreadNavigationAction: @escaping MessageThreadNavigationAction = {_ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ViewModelsFactory.makeChannelViewModel(
                with: channelController,
                messageController: messageController,
                scrollToMessage: nil
            )
        )
        factory = viewFactory
        self.channel = channel
        self.messageId = messageId
        self.onReloadChannelHeader = onReloadChannelHeader
        self.channelControllerBuilder = channelControllerBuilder
        self.messageThreadNavigationAction = messageThreadNavigationAction
    }

    private var shouldPresentOverlay: Bool {
        viewModel.reactionsShown && messageDisplayInfo != nil
    }

    // Dismiss the reactions overlay if it is presented
    private func dismissOverlayIfNeeded(animated: Bool = true) {
        guard viewModel.reactionsShown || messageDisplayInfo != nil else { return }
        let changes = {
            self.messageDisplayInfo = nil
            self.viewModel.reactionsShown = false
        }
        if animated {
            withAnimation {
                changes()
            }
        } else {
            changes()
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if !viewModel.messages.isEmpty {
                    CustomMessageListContainerView(
                        factory: factory,
                        channel: channel,
                        messages: viewModel.messages,
                        messagesGroupingInfo: viewModel.messagesGroupingInfo,
                        scrolledId: $viewModel.scrolledId,
                        showScrollToLatestButton: $viewModel.showScrollToLatestButton,
                        quotedMessage: $viewModel.quotedMessage,
                        currentDateString: viewModel.currentDateString,
                        listId: viewModel.listId,
                        isMessageThread: viewModel.isMessageThread,
                        shouldShowTypingIndicator: viewModel.shouldShowTypingIndicator,
                        scrollPosition: $viewModel.scrollPosition,
                        loadingNextMessages: viewModel.loadingNextMessages,
                        firstUnreadMessageId: $viewModel.firstUnreadMessageId,
                        onMessageAppear:
                            viewModel.handleMessageAppear(index:scrollDirection:),
                        onScrollToBottom: viewModel.scrollToLastMessage,
                        onLongPress: { displayInfo in
                            messageDisplayInfo = displayInfo
                            withAnimation {
                                viewModel.showReactionOverlay(for: AnyView(self))
                            }
                        },
                        onJumpToMessage: viewModel.jumpToMessage(messageId:)
                    )
                    .ignoresSafeArea(edges: [.bottom])
                    .onAppear {
                        if let messageId {
                            _ = viewModel.jumpToMessage(messageId: messageId)
                        }
                    }
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.04), .black.opacity(0)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(maxWidth: .infinity, maxHeight: 18)
                    }
                    .overlay(
                        viewModel.currentDateString != nil ?
                        factory.makeDateIndicatorView(dateString: viewModel.currentDateString!)
                        : nil
                    )
                } else {
                    ZStack {
                        factory.makeEmptyMessagesView(for: channel, colors: colors)
                        if viewModel.shouldShowTypingIndicator {
                            factory.makeTypingIndicatorBottomView(
                                channel: channel,
                                currentUserId: chatClient.currentUserId
                            )
                        }
                    }
                }

                Divider()

                    .if(viewModel.channelHeaderType == .regular) { _ in
                        reloadHeaderEmptyView
                    }
                    .if(viewModel.channelHeaderType == .typingIndicator) { _ in
                        reloadHeaderEmptyView
                    }

                if channel.isSupportChatChannel {
                    CustomSupportChatChannelButton()
                } else if isInputDisabled && channel.relatedConceptType.isCommunity {
                    // hide input view
                } else {
                    factory.makeMessageComposerViewType(
                        with: viewModel.channelController,
                        messageController: viewModel.messageController,
                        quotedMessage: $viewModel.quotedMessage,
                        editedMessage: $viewModel.editedMessage,
                        onMessageSent: viewModel.scrollToLastMessage
                    )
                    .disabled(isInputDisabled)
                    .opacity(isInputDisabled ? 0.4 : 1)
                }
            }
            .accentColor(colors.tintColor)
        }
        .onChange(of: viewModel.threadMessage) { newValue in
            if let message = newValue {
                // Ensure overlay is dismissed before navigating
                dismissOverlayIfNeeded(animated: true)

                messageThreadNavigationAction(
                    MessageThreadChannelViewData(
                        navigationTitle: channel.name ?? "",
                        channelId: channel.cid.rawValue,
                        messageId: message.id
                    )
                )

                // reset for onChange retrigger.
                messageDisplayInfo = nil
                viewModel.threadMessage = nil
            }
        }
        .overlayPresenter(
            isPresented: Binding(
                get: { shouldPresentOverlay },
                set: { newValue in

                    if !newValue {
                        messageDisplayInfo = nil
                        viewModel.reactionsShown = false
                    }
                }
            ),
            transition: .crossDissolve
        ) {
            if let mdi = messageDisplayInfo {
                CustomReactionsOverlayView(
                    factory: factory,
                    channel: channel,
                    messageDisplayInfo: mdi
                ) {
                    withAnimation {
                        viewModel.reactionsShown = false
                    }
                } onActionExecuted: { actionInfo in
                    viewModel.messageActionExecuted(actionInfo)
                    withAnimation {
                        viewModel.reactionsShown = false
                    }
                }
                .ignoresSafeArea()

            } else {
                Color.clear.ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.22), value: viewModel.reactionsShown)
    }

    var reloadHeaderEmptyView: some View {
        ZStack {
            EmptyView()
        }
        .onAppear {
            onReloadChannelHeader?(channel)
        }
    }

    var isInputDisabled: Bool {
        !viewModel.canSendMessage
    }
}
