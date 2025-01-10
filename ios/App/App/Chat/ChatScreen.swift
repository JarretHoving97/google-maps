import SwiftUI
import StreamChat
import StreamChatSwiftUI

class LocaleSettings: ObservableObject {

    @Published var locale = Locale.current

    @Published var languageLocale = Locale(identifier: String(Locale.current.identifier.prefix(2)))

    static var shared = LocaleSettings()

    var bundle: Bundle? {
        guard let path = Bundle.main.path(forResource: languageLocale.identifier, ofType: "lproj"), let bundle = Bundle(path: path) else {
            return nil
        }

        return bundle
    }
}

/// Screen component for the chat channel view.
public struct ChatChannelScreen: View {

    public var chatChannelController: ChatChannelController
    @ObservedObject var viewModel: ChatChannelListViewModel

    var onDidLoadChannel: ((ChatChannel) -> Void)?
    var onChatWithHostTapped: ((String?) -> Void)?

    private var messageId: String?

    init(chatChannelController: ChatChannelController, viewModel: ChatChannelListViewModel, messageId: String?) {
        self.chatChannelController = chatChannelController
        self.viewModel = viewModel
        self.messageId = messageId
    }

    @ViewBuilder
    private func customViewOverlay() -> some View {
        switch viewModel.customChannelPopupType {
        case let .moreActions(channel):
            CustomUIFactory.shared.makeMoreChannelActionsView(
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
            viewFactory: CustomUIFactory.shared,
            messageId: messageId,
            channelController: chatChannelController,
            onDidLoadChannel: onDidLoadChannel,
            onChatWithHostTapped: onChatWithHostTapped
        )
        .environment(\.attachmentController, AttachmentEnvironmentController())
        .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
    }
}

struct ChatScreen: View {
    @Injected(\.chatClient) private var chatClient

    @ObservedObject private var localeSettings = LocaleSettings.shared

    @ObservedObject private var chatViewModel: ChatViewModel

    @StateObject private var viewModel: ChatChannelListViewModel

    private var channelListController: ChatChannelListController?

    var onItemTapped: ((ChatChannel) -> Void)?

    private let onBackButtonTapped: (() -> Void)?

    init(chatViewModel: ChatViewModel, onBackButtonTapped: (() -> Void)?) {
        self.chatViewModel = chatViewModel
        self.onBackButtonTapped = onBackButtonTapped
        var channelListController: ChatChannelListController? {
            if let currentUserId = StreamChatWrapper.shared.client?.currentUserId {
                return StreamChatWrapper.shared.client!.channelListController(
                    query: .init(filter: .and([
                        .equal(.type, to: .messaging),
                        .containMembers(userIds: [currentUserId]),
                        .exists(.lastMessageAt)
                    ]))
                )
            }
            return nil
        }
        self.channelListController = channelListController
        _viewModel = StateObject(wrappedValue: ChatChannelListViewModel(channelListController: channelListController))
    }

    var view: some View {
        ChatChannelsScreen(
            viewModel: viewModel,
            chatViewModel: chatViewModel,
            channelListController: channelListController!,
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

    var body: some View {
        view
            .environmentObject(viewModel)
            .environmentObject(localeSettings)
            .environmentObject(chatViewModel)
            .environment(\.locale, localeSettings.locale)
            .environment(\.font, Font.custom(size: 15, weight: .regular))
    }
}
