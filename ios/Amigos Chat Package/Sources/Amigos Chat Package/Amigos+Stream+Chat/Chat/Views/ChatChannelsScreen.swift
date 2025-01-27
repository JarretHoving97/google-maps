import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct ChatChannelsScreen: View {

    @ObservedObject var chatViewModel: ChatViewModel

    @ObservedObject private var viewModel: ChatChannelListViewModel

    private var channelListController: ChatChannelListController

    private let onItemTapped: ((ChatChannel) -> Void)?

    private let viewFactory: CustomUIFactory

    init(with viewFactory: CustomUIFactory, viewModel: ChatChannelListViewModel, chatViewModel: ChatViewModel, channelListController: ChatChannelListController, onItemTapped: @escaping ((ChatChannel) -> Void)) {
        self.viewModel = viewModel
        self.chatViewModel = chatViewModel
        self.channelListController = channelListController
        self.onItemTapped = onItemTapped
        self.viewFactory = viewFactory
    }

    var body: some View {
        CustomChatChannelListView(
            viewFactory: viewFactory,
            viewModel: viewModel,
            title: chatViewModel.title,
            onItemTap: onItemTapped,
            embedInNavigationView: false
        )
        .onAppear {
            ChatControllers.channelListController?.synchronize()

            channelListController.synchronize { error in
                if let error {
                    print("Failed synchronizing channels:", error)
                    return
                }
            }
        }
    }
}
