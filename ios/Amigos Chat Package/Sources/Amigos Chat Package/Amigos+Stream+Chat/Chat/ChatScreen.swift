import SwiftUI
import StreamChat
import StreamChatSwiftUI

/// Screen component for the chat channel view.
public struct ChatChannelScreen: View {

    public var chatChannelController: ChatChannelController
    @ObservedObject var viewModel: ChatChannelListViewModel
    var onDidLoadChannel: ((ChatChannel) -> Void)?

    private let viewFactory: CustomUIFactory

    private var messageId: String?

    var onChatWithHostTapped: ((String?) -> Void)?

    init(with viewFactory: CustomUIFactory, chatChannelController: ChatChannelController, viewModel: ChatChannelListViewModel,  messageId: String?) {
        self.chatChannelController = chatChannelController
        self.viewModel = viewModel
        self.messageId = messageId
        self.viewFactory = viewFactory
    }

    @ViewBuilder
    private func customViewOverlay() -> some View {
        switch viewModel.customChannelPopupType {
        case let .moreActions(channel):
            viewFactory.makeMoreChannelActionsView(
                for: channel,
                swipedChannelId: $viewModel.swipedChannelId
            ) {
                withAnimation {
                    viewModel.customChannelPopupType = nil
                    viewModel.swipedChannelId = nil
                }
            } onError: { error in
                viewModel.showErrorPopup(error)
            }
            .edgesIgnoringSafeArea(.bottom)
        default:
            EmptyView()
        }
    }

    public var body: some View {
        CustomChatChannelView(
            viewFactory: viewFactory,
            messageId: messageId,
            channelController: chatChannelController,
            onDidLoadChannel: onDidLoadChannel,
            onChatWithHostTapped: onChatWithHostTapped
        )
        .environment(\.attachmentController, AttachmentEnvironmentController())
        .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
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

    init(with viewFactory: CustomUIFactory, channelListController: ChatChannelListController, chatViewModel: ChatViewModel, onBackButtonTapped: (() -> Void)?) {
        self.chatViewModel = chatViewModel
        self.onBackButtonTapped = onBackButtonTapped
        self.viewFactory = viewFactory
        self.channelListController = channelListController
        _viewModel = StateObject(wrappedValue: ChatChannelListViewModel(channelListController: channelListController))
    }

    var view: some View {
        ChatChannelsScreen(
            with: viewFactory,
            viewModel: viewModel,
            chatViewModel: chatViewModel,
            channelListController: channelListController,
            onItemTapped: onItemTapped ?? { _ in }
        )
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

    public var body: some View {
        view
            .environmentObject(viewModel)
            .environmentObject(chatViewModel)
            .environment(\.font, Font.custom(size: 15, weight: .regular))
    }
}
