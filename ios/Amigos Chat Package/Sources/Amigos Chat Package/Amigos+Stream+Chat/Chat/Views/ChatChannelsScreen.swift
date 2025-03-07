import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct ChatChannelsScreen: View {

    @ObservedObject var chatViewModel: ChatViewModel

    private var channelListController: ChatChannelListController

    private let onItemTapped: ((ChatChannel) -> Void)?

    private let viewFactory: CustomUIFactory

    init(with viewFactory: CustomUIFactory, chatViewModel: ChatViewModel, channelListController: ChatChannelListController, onItemTapped: @escaping ((ChatChannel) -> Void)) {
        self.chatViewModel = chatViewModel
        self.channelListController = channelListController
        self.onItemTapped = onItemTapped
        self.viewFactory = viewFactory
    }

    var body: some View {
        CustomChatChannelListView(
            viewFactory: viewFactory,
            title: chatViewModel.title,
            onItemTap: onItemTapped,
            embedInNavigationView: false
        )
    }
}
