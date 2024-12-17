import UIKit
import SwiftUI
import StreamChat

struct ChannelInfo {
    let messageId: String?
    let channelId: String

    init(messageId: String? = nil, channelId: String) {
        self.messageId = messageId
        self.channelId = channelId
    }
}

extension ChannelInfo {
    var streamChannelId: ChannelId? {
        try? ChannelId(cid: channelId)
    }
}

class ChatViewModel: ObservableObject {
    @Published public var isChannelView: Bool = false

    let info: ChannelInfo?

    init(info: ChannelInfo? = nil) {
        self.isChannelView = info != nil
        self.info = info
    }
}

class ChatViewController: UIViewController {
    var chatViewModel = ChatViewModel()
    var rootView: ChatScreen?
    var hostingController: UIHostingController<ChatScreen>?

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView = ChatScreen(chatViewModel: chatViewModel)

        hostingController = UIHostingController(rootView: rootView!)

        if let hostingController {
            addChild(hostingController)

            hostingController.view.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(hostingController.view)

            hostingController.didMove(toParent: self)

            NSLayoutConstraint.activate([
                hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
                hostingController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
                hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
}
