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
    let messageId: String?
    @ObservedObject private var viewModel: ChatChannelListViewModel

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
            channelController: chatChannelController
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

    init(chatViewModel: ChatViewModel) {
        self.chatViewModel = chatViewModel

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
        NavigationView {
            if let channelId = chatViewModel.info?.streamChannelId {
                ChatChannelScreen(
                    chatChannelController: chatClient.channelController(
                        for: channelId),
                    viewModel: viewModel,
                    messageId: chatViewModel.info?.messageId
                )
            } else if let channelListController {
                ChatChannelsScreen(viewModel: viewModel, chatViewModel: chatViewModel, channelListController: channelListController)
                    // reset appIcon badge count when channels are loaded.
                    .onChange(of: viewModel.channels) { channels in
                        if !channels.isEmpty {
                            UNUserNotificationCenter.resetAppBadge()
                        }
                    }
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
