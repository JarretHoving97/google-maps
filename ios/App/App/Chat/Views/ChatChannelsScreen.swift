import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct ChatChannelsScreen: View {

    @ObservedObject var localeSettings = LocaleSettings.shared

    @ObservedObject var chatViewModel: ChatViewModel

    @ObservedObject private var viewModel: ChatChannelListViewModel

    private var channelListController: ChatChannelListController

    private let onItemTapped: ((ChatChannel) -> Void)?

    init(viewModel: ChatChannelListViewModel, chatViewModel: ChatViewModel, channelListController: ChatChannelListController, onItemTapped: @escaping ((ChatChannel) -> Void)) {
        self.viewModel = viewModel
        self.chatViewModel = chatViewModel
        self.channelListController = channelListController
        self.onItemTapped = onItemTapped
    }

    var body: some View {
        CustomChatChannelListView(
            viewFactory: CustomUIFactory.shared,
            viewModel: viewModel,
            title: chatViewModel.title,
            onItemTap: onItemTapped,
            embedInNavigationView: false
        )
        .onAppear {
            StreamChatWrapper.shared.client?.currentUserController().synchronize()

            channelListController.synchronize { error in
                if let error {
                    print("Failed synchronizing channels:", error)
                    return
                }
            }
        }
    }
}
