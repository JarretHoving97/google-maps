import SwiftUI
import StreamChat
import StreamChatSwiftUI

public class ChatChannelScreenViewModel: ObservableObject {

    @Published private(set) var popOver: PopoverType?

    let isDirectMessageChannel: Bool

    public init(isDirectMessageChannel: Bool) {
        self.isDirectMessageChannel = isDirectMessageChannel
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

    @StateObject var viewModel: ChatChannelScreenViewModel

    @Environment(\.presentationMode) var presentationMode

    public var chatChannelController: ChatChannelController

    var onDidLoadChannel: ((ChatChannel) -> Void)?

    var headerButtonTapHandler: HeaderButtonActionHandler?

    private let viewFactory: CustomUIFactory

    private var messageId: String?

    private let messageThreadNavigationAction: MessageThreadNavigationAction

    public init(
        with viewFactory: CustomUIFactory,
        chatChannelController: ChatChannelController,
        viewModel: ChatChannelScreenViewModel,
        messageId: String?,
        messageThreadNavigationAction: @escaping MessageThreadNavigationAction = {_ in }
    ) {
        self.chatChannelController = chatChannelController
        self.messageId = messageId
        self.viewFactory = viewFactory
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.messageThreadNavigationAction = messageThreadNavigationAction
    }

    public var body: some View {

        CustomChatChannelView(
            viewFactory: viewFactory,
            messageId: messageId,
            channelController: chatChannelController,
            onDidLoadChannel: onDidLoadChannel,
            headerButtonTapHandler: headerButtonTapHandler,
            messageThreadNavigationAction: messageThreadNavigationAction
        )
        .onAppear { chatChannelController.markRead() }
        .environment(\.attachmentController, AttachmentEnvironmentController())
        .environment(\.showConsentMediaInGroupChannel, viewModel.isDirectMessageChannel)
        .overlay(customViewOverlay(popOver: viewModel.popOver).ignoresSafeArea(edges: [.top]))

    }

    @ViewBuilder
    private func customViewOverlay(popOver: PopoverType?) -> some View {

        if case let .moreActions(channel) = viewModel.popOver {

            let callbacks = ChannelActionCallbacks(
                onDismiss: { viewModel.toggle(popOver: nil) },
                onError: { viewModel.toggle(popOver: .error($0)) },
                onClose: { presentationMode.wrappedValue.dismiss() }
            )

            CustomMoreChannelActionsContainerView(
                factory: viewFactory,
                channel: channel,
                callbacks: callbacks
            )
        }
    }
}

public struct ChatScreen: View {
    @Injected(\.chatClient) private var chatClient

    @ObservedObject private var chatViewModel: ChatViewModel

    @StateObject private var viewModel: ChatChannelListViewModel

    private var channelListController: ChatChannelListController

    public var onItemTapped: ((ChatChannel) -> Void)?

    private let onBackButtonTapped: (() -> Void)?

    private let viewFactory: CustomUIFactory

    init(
        with viewFactory: CustomUIFactory,
        channelListController: ChatChannelListController,
        chatViewModel: ChatViewModel,
        onBackButtonTapped: (() -> Void)?
    ) {
        self.chatViewModel = chatViewModel
        self.onBackButtonTapped = onBackButtonTapped
        self.viewFactory = viewFactory
        self.channelListController = channelListController
        _viewModel = StateObject(wrappedValue: ChatChannelListViewModel(channelListController: channelListController))
    }

    public var body: some View {
        CustomChatChannelListView(
            viewFactory: viewFactory,
            viewModel: viewModel,
            title: chatViewModel.title,
            onItemTap: onItemTapped,
            embedInNavigationView: false
        )
        .environment(\.font, Font.custom(size: 15, weight: .regular))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    onBackButtonTapped?()
                } label: {
                    Image(.amiBackButton)
                        .foregroundStyle(Color(.purple))
                }
            }
        }
        // reset appIcon badge count when channels are loaded.
        .onChange(of: viewModel.channels) { channels in
            if !channels.isEmpty {
                UNUserNotificationCenter.resetAppBadge()
            }
        }
    }
}
