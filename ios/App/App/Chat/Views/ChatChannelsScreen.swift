import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct ChatChannelsScreen: View {
    
    @ObservedObject var localeSettings = LocaleSettings.shared
    
    @ObservedObject var chatViewModel: ChatViewModel
    
    @ObservedObject private var viewModel: ChatChannelListViewModel
    
    private var channelListController: ChatChannelListController
    
    init(viewModel: ChatChannelListViewModel, chatViewModel: ChatViewModel, channelListController: ChatChannelListController) {
        self.viewModel = viewModel
        self.chatViewModel = chatViewModel
        self.channelListController = channelListController
    }
    
    func onItemTap(channel: ChatChannel? = nil) {
        if let channel = channel {
            viewModel.selectedChannel = channel.channelSelectionInfo
            ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: "/channel/\(channel.cid.rawValue)")
        }
    }
    
    var body: some View {
        ChatChannelListView(
            viewFactory: CustomUIFactory.shared,
            viewModel: viewModel,
            onItemTap: onItemTap
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
