import UIKit
import SwiftUI
import StreamChat

class ChatViewModel: ObservableObject {
    @Published public var channelId: ChannelId?
    @Published public var isChannelView: Bool = false

    var title: String {
        NSLocalizedString("custom.channelList.title", comment: "Toolbar title for open chats")
    }

    init(channelId: ChannelId? = nil, isChannelView: Bool? = nil) {
        self.channelId = channelId
        self.isChannelView = isChannelView ?? false
    }
}
