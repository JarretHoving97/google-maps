import Foundation
import SwiftUI
import StreamChat
import StreamChatSwiftUI

public final class StreamChatWrapper {
    public static let shared = StreamChatWrapper()

    // Chat client
    var client: ChatClient?
    
    // Stream chat
    var chat: StreamChat?

    // ChatClient config
    var config: ChatClientConfig {
        didSet {
            setUpChat()
        }
    }
    
    private var currentUserController: CurrentChatUserController?
    private var delegate: CurrentUserDelegate?

    public init() {
        var _config = ChatClientConfig(apiKey: .init(BuildConfiguration.StreamApiKey))
        
        if let bundleId = Bundle.main.bundleIdentifier {
            _config.isLocalStorageEnabled = true
            _config.applicationGroupIdentifier = "group.\(bundleId).stream"
        }
        
        _config.maxAttachmentCountPerMessage = 5
        
        config = _config
    }
    
    func setUpChat() {
        // Create Client
        if client == nil {
            client = ChatClient(config: config)
            
            Appearance.localizationProvider = { key, table in
                tr(key)
            }
            
            if let client {
                chat = StreamChat(chatClient: client, appearance: getAppearence(), utils: getUtils())
            }
        }
    }
    
    func logIn(id: String, name: String?, avatarUrl: String?) {
        setUpChat()
        
        var extraData: [String : RawJSON] = [:]
        
        if let avatarUrl {
            extraData = ["image": .string(avatarUrl)]
        }
        
        let userInfo: UserInfo = .init(
            id: id, 
            name: name,
            extraData: extraData
        )
        
        client!.connectUser(
            userInfo: userInfo,
            tokenProvider: loadStreamToken
        ) { error in
            if let error = error {
                log.error("[Stream] Connecting the user failed: \(error)")
                return
            }
            
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            
            self.setupCurrentUserController()
        }
    }
    
    /// Disconnects the user and removes related cache.
    public func logOut() {
        setUpChat()
        
        // We don't want to send push notifications related to this user to this device again.
        removeDeviceToken()
        
        // The docs says to use `disconnect` when logging out but `logout` makes more sense to me.
        client!.logout(completion: {})
    }
    
    /// Adds the device token to stream so push notifications can be sent.
    public func addDeviceToken(deviceToken: String) {
        setUpChat()
        
        guard client!.currentUserId != nil else {
            log.warning("[Stream] Failed adding the device as the user is unauthenticated.")
            return
        }
        
        client!.currentUserController().addDevice(.firebase(token: deviceToken, providerName: "Firebase")) { error in
            if let error = error {
                log.warning("[Stream] Failed adding the device: \(error)")
            }
        }
    }
    
    public func removeDeviceToken() {
        setUpChat()
        
        guard let deviceId = client!.currentUserController().currentUser?.devices.last?.id else {
            return
        }

        client!.currentUserController().removeDevice(id: deviceId) { error in
            if let error = error {
                log.warning("[Stream] Failed removing the device: \(error)")
            }
        }
    }
    
    public func getUtils() -> Utils {
        return Utils(
            commandsConfig: CustomCommandsConfig(),
            messageListConfig: customMessageListConfig,
            composerConfig: ComposerConfig(
                isVoiceRecordingEnabled: true,
                inputViewCornerRadius: 16,
                inputFont: UIFont(name: "Poppins-Regular", size: 14)!,
                inputPaddingsConfig: PaddingsConfig(top: 4, bottom: 4, leading: 4, trailing: 4)
            ),
            channelHeaderLoader: CustomChannelHeaderLoader()
        )
    }
    
    /// Get the `Appearance` to specify when initializing `StreamChat`.
    private func getAppearence() -> Appearance {
        var colors = ColorPalette()

        colors.quotedMessageBackgroundCurrentUser = UIColor(white: 0.0, alpha: 0.05);
        colors.quotedMessageBackgroundOtherUser = UIColor(white: 0.0, alpha: 0.05);
        colors.messageCurrentUserBackground = [UIColor(Color("Purple"))]
        colors.messageOtherUserBackground = [UIColor.white]
        colors.messageCurrentUserTextColor = UIColor.white;
        colors.tintColor = Color("Purple")
        colors.background = UIColor(Color("Pale"))

        let images = Images()
        
        images.availableReactions = [
            .init(rawValue: "heart"): ChatMessageReactionAppearance(
                smallIcon: "❤️".toImage(size: 64),
                largeIcon: "❤️".toImage(size: 256)
            ),
            .init(rawValue: "tears-of-joy"): ChatMessageReactionAppearance(
                smallIcon: "😂".toImage(size: 64),
                largeIcon: "😂".toImage(size: 256)
            ),
            .init(rawValue: "thumbs-up"): ChatMessageReactionAppearance(
                smallIcon: "👍".toImage(size: 64),
                largeIcon: "👍".toImage(size: 256)
            ),
            .init(rawValue: "astonished"): ChatMessageReactionAppearance(
                smallIcon: "😲".toImage(size: 64),
                largeIcon: "😲".toImage(size: 256)
            ),
            .init(rawValue: "fire"): ChatMessageReactionAppearance(
                smallIcon: "🔥".toImage(size: 64),
                largeIcon: "🔥".toImage(size: 256)
            )
        ]
        
        images.sliderThumb = UIImage(named: "SliderThumb")!

        return Appearance(colors: colors, images: images, fonts: Fonts())
    }
    
    private func setupCurrentUserController() {
        currentUserController = client?.currentUserController()
        delegate = CurrentUserDelegate()
        currentUserController?.delegate = delegate
        currentUserController?.synchronize()
    }
}

class CurrentUserDelegate: CurrentChatUserControllerDelegate {
    func currentUserController(_ controller: CurrentChatUserController, didChangeCurrentUserUnreadCount unreadCount: UnreadCount) {
        ExtendedStreamPlugin.shared.notifyUnreadCounts(
            channelUnreadCount: unreadCount.channels,
            messageUnreadCount: unreadCount.messages
        )
    }
}

class CustomCommandsConfig: CommandsConfig {
    
    public let mentionsSymbol: String = "@"
    
    public let instantCommandsSymbol: String = "/"
    
    public func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler {
        let mentionsCommand = MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: mentionsSymbol,
            mentionAllAppUsers: false
        )
        
        return CommandsHandler(commands: [mentionsCommand])
    }
}

let customMessageListConfig = MessageListConfig(
    typingIndicatorPlacement: .navigationBar,
    messageDisplayOptions: MessageDisplayOptions(
        showAvatars: false,
        showAvatarsInGroups: true,
        reactionsPlacement: .bottom
        
    ),
    messagePaddings: MessagePaddings(horizontal: 12),
    dateIndicatorPlacement: .messageList,
    uniqueReactionsEnabled: true,
    markdownSupportEnabled: false
)
