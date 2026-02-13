import SwiftUI
import StreamChat
import StreamChatSwiftUI

public class ChatChannelScreenViewModel: ObservableObject {

    @Published private(set) var popOver: PopoverType?

    let isDirectMessageChannel: Bool

    var channel: ChatChannel?

    init(isDirectMessageChannel: Bool, channel: ChatChannel?) {
        self.isDirectMessageChannel = isDirectMessageChannel
        self.channel = channel
    }

    @MainActor
    public func toggle(popOver: PopoverType?) {
        if self.popOver == popOver {
            self.popOver = nil
        } else {
            self.popOver = popOver
        }
    }
}

public enum PopoverType: Equatable {

    case moreActions(ChatChannel)
    case error(Error)

    public static func == (lhs: PopoverType, rhs: PopoverType) -> Bool {
        switch (lhs, rhs) {
        case (.moreActions(let lhsChannel), .moreActions(let rhsChannel)):
            return lhsChannel.id == rhsChannel.id
        default:
            return false
        }
    }
}

/// Screen component for the chat channel view.
public struct ChatChannelScreen: View {

    @Injected(\.chatRouter) var router

    @StateObject var viewModel: ChatChannelScreenViewModel

    @StateObject var messageComposerViewModel: MessageComposerViewModel

    @Environment(\.presentationMode) var presentationMode

    private let chatClient: ChatClient

    public var chatChannelController: ChatChannelController

    var onDidLoadChannel: ((ChatChannel) -> Void)?

    private let viewFactory: CustomUIFactory

    private var messageId: String?

    private let messageThreadNavigationAction: MessageThreadNavigationAction

    private let messageActionsViewBuilder: OnCreateMessageActionsFactory?

    private var shouldPresentOverlay: Bool {
        viewModel.popOver != nil
    }

    public init(
        with viewFactory: CustomUIFactory,
        chatClient: ChatClient,
        chatChannelController: ChatChannelController,
        viewModel: ChatChannelScreenViewModel,
        messageId: String?,
        messageThreadNavigationAction: @escaping MessageThreadNavigationAction = {_ in },
        messageActionsViewBuilder: OnCreateMessageActionsFactory? = nil,
    ) {
        self.chatClient = chatClient
        self.chatChannelController = chatChannelController
        self.messageId = messageId
        self.viewFactory = viewFactory
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.messageThreadNavigationAction = messageThreadNavigationAction
        self.messageActionsViewBuilder = messageActionsViewBuilder

        _messageComposerViewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeMessageComposerViewModel(
                with: chatChannelController,
                messageController: nil,
                quotedMessage: nil
            )
        )
    }

    public var body: some View {
        CustomChatChannelView(
            viewFactory: viewFactory,
            messageComposerViewModel: messageComposerViewModel,
            messageId: messageId,
            channelController: chatChannelController,
            onDidLoadChannel: onDidLoadChannel,
            messageThreadNavigationAction: messageThreadNavigationAction,
            messageActionsViewBuilder: messageActionsViewBuilder
        )
        .onAppear { chatChannelController.markRead() }
        .environment(\.attachmentController, AttachmentEnvironmentController())
        .environment(\.showConsentMediaInGroupChannel, viewModel.isDirectMessageChannel)
        .toolbar {
            if let channel = viewModel.channel {
                ChatToolbarButtons(
                    router: router,
                    channel: channel,
                    onMoreTapped: { viewModel.toggle(popOver: .moreActions(channel))
                    }
                )
            }
        }
        .overlayPresenter(
            isPresented: Binding(
                get: { shouldPresentOverlay },
                set: { newValue in
                    if !newValue {
                        viewModel.toggle(popOver: nil)
                    }
                }
            ),
            content: {
                if let channel = viewModel.channel {
                    ChannelActionsViewStreamContainer(
                        router: router,
                        channel: channel,
                        chatClient: chatClient,
                        onDismiss: {
                            viewModel.toggle(popOver: nil)
                            presentationMode.wrappedValue.dismiss()
                        },
                        onError: { error in
                            viewModel.toggle(popOver: .error(error))
                        },
                        onClose: closePopOver
                    )
                }
            }
        )
    }

    private func closePopOver(_ info: ChannelActionCallbacks.Info?) {

        if let info {
            self.viewModel.channel = info.channel
        }

        withAnimation {
            viewModel.toggle(popOver: nil)
        }
    }
}
public struct ChatScreen: View {

    @Injected(\.chatClient) private var chatClient

    @ObservedObject private var chatViewModel: ChatViewModel

    @StateObject private var viewModel: ChatChannelListViewModel

    private var channelListController: ChatChannelListController

    private let viewFactory: CustomUIFactory

    init(
        with viewFactory: CustomUIFactory,
        channelListController: ChatChannelListController,
        chatViewModel: ChatViewModel,
    ) {
        self.chatViewModel = chatViewModel
        self.viewFactory = viewFactory
        self.channelListController = channelListController
        _viewModel = StateObject(wrappedValue: ChatChannelListViewModel(channelListController: channelListController))
    }

    public var body: some View {
        CustomChatChannelListView(
            viewFactory: viewFactory,
            viewModel: viewModel,
            title: chatViewModel.title,
            embedInNavigationView: false
        )
        .navigationTitle(tr("custom.channelList.title"))
        .environment(\.font, Font.custom(size: 15, weight: .regular))
        // reset appIcon badge count when channels are loaded.
        .onChange(of: viewModel.channels) { channels in
            if !channels.isEmpty {
                UNUserNotificationCenter.resetAppBadge()
            }
        }
    }
}
