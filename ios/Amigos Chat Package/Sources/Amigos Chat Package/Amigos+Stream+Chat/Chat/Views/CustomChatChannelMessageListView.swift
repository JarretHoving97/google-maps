import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomChatChannelMessageListView<Factory: ViewFactory>: View {

    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    @StateObject private var viewModel: ChatChannelViewModel

    @Environment(\.presentationMode) var presentationMode

    @State private var messageDisplayInfo: MessageDisplayInfo?
    @State private var tabBarAvailable: Bool = false

    private var factory: Factory

    private let channel: ChatChannel

    private let messageId: String?

    public init(
        viewFactory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        viewModel: ChatChannelViewModel? = nil,
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        messageId: String? = nil
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
    }

    var body: some View {
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
                    onMessageAppear: viewModel.handleMessageAppear(index:scrollDirection:),
                    onScrollToBottom: viewModel.scrollToLastMessage,
                    onLongPress: { displayInfo in
                        messageDisplayInfo = displayInfo
                        withAnimation {
                            viewModel.showReactionOverlay(for: AnyView(self))
                        }
                    },
                    onJumpToMessage: viewModel.jumpToMessage(messageId:)
                )
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
                .navigationBarBackButtonHidden(viewModel.reactionsShown)
                .if(viewModel.reactionsShown, transform: { view in
                    view.navigationBarHidden(true)
                })
                .if(!viewModel.reactionsShown, transform: { view in
                    view.navigationBarHidden(false)
                })
                .if(viewModel.channelHeaderType == .typingIndicator) { view in
                    view.modifier(factory.makeChannelHeaderViewModifier(for: channel))
                }
                .if(viewModel.channelHeaderType == .messageThread) { view in
                    view.modifier(factory.makeMessageThreadHeaderViewModifier())
                }
                .animation(nil)

            if channel.isSupportChatChannel {
                CustomSupportChatChannelButton()
            } else {
                factory.makeMessageComposerViewType(
                    with: viewModel.channelController,
                    messageController: viewModel.messageController,
                    quotedMessage: $viewModel.quotedMessage,
                    editedMessage: $viewModel.editedMessage,
                    onMessageSent: viewModel.scrollToLastMessage
                )
                .opacity((
                    utils.messageListConfig.messagePopoverEnabled && messageDisplayInfo != nil && !viewModel
                        .reactionsShown && viewModel.channel?.isFrozen == false
                ) ? 0 : 1)
            }

            NavigationLink(
                isActive: $viewModel.threadMessageShown
            ) {
                if let message = viewModel.threadMessage {
                    let threadDestination = factory.makeMessageThreadDestination()
                    threadDestination(channel, message)
                } else {
                    EmptyView()
                }
            } label: {
                EmptyView()
            }
        }
        .accentColor(colors.tintColor)
        .overlay(
            viewModel.reactionsShown ?
            factory.makeReactionsOverlayView(
                channel: channel,
                currentSnapshot: viewModel.currentSnapshot!,
                messageDisplayInfo: messageDisplayInfo!,
                onBackgroundTap: {
                    viewModel.reactionsShown = false
                    messageDisplayInfo = nil
                }, onActionExecuted: { actionInfo in
                    viewModel.messageActionExecuted(actionInfo)
                    messageDisplayInfo = nil
                }
            )
            .transition(.identity)
            .edgesIgnoringSafeArea(.all)
            : nil
        )
    }
}
