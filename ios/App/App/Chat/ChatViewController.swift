import UIKit
import SwiftUI
import StreamChat

class ChatViewModel: ObservableObject {
    @Published public var channelId: ChannelId?
    @Published public var isChannelView: Bool = false
    
    init(channelId: ChannelId? = nil, isChannelView: Bool? = nil) {
        self.channelId = channelId
        self.isChannelView = isChannelView ?? false
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
