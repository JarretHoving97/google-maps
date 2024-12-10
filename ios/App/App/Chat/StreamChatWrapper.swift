// swiftlint:disable all
import Foundation
import SwiftUI
import StreamChat
import StreamChatSwiftUI

public final class StreamChatWrapper {
    
    public static var shared = StreamChatWrapper()
    
    private init() {}

    // Chat client
    private(set) var client: ChatClient?
    
    // Stream chat
    private(set) var chat: StreamChat?
    
    private var currentUserController: CurrentChatUserController?
    private var delegate: CurrentUserDelegate?
    
    private var environment: BuildConfiguration?
    
    public func buildFor(environment: BuildConfiguration) {
        
        self.environment = environment
        
        var config = ChatClientConfig(apiKey: APIKey(environment.StreamApiKey))
    
            if let bundleId = Bundle.main.bundleIdentifier {
                config.isLocalStorageEnabled = true
                config.applicationGroupIdentifier = "group.\(bundleId).stream"
            }
            
            config.maxAttachmentCountPerMessage = 5
        
        setupChat(with: ChatClient(config: config))
    }

    private func setupChat(with client: ChatClient) {
        
        Appearance.localizationProvider = { key, table in
            tr(key)
        }
        
        self.client = client
        self.chat = StreamChat(chatClient: client, appearance: getAppearence())
    }

    func logIn(id: String, name: String?, avatarUrl: String?) {
        
        guard let environment else { return }
        
        var extraData: [String : RawJSON] = [:]
        
        if let avatarUrl {
            extraData = ["image": .string(avatarUrl)]
        }

        let userInfo: UserInfo = .init(
            id: id,
            name: name,
            extraData: extraData
        )
        
        client?.connectUser(
            userInfo: userInfo,
            tokenProvider: { loadStreamToken(environment.AmigosApiUrl, $0) }
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
        // We don't want to send push notifications related to this user to this device again.
        removeDeviceToken()

        // The docs says to use `disconnect` when logging out but `logout` makes more sense to me.
        client?.logout(completion: {})
    }

    /// Adds the device token to stream so push notifications can be sent.
    public func addDeviceToken(deviceToken: String) {
        
        guard client?.currentUserId != nil else {
            log.warning("[Stream] Failed adding the device as the user is unauthenticated.")
            return
        }
        
        client?.currentUserController().addDevice(.firebase(token: deviceToken, providerName: "Firebase")) { error in
            
            if let error = error {
                log.warning("[Stream] Failed adding the device: \(error)")
            }
        }
    }

    public func removeDeviceToken() {
    
        guard let deviceId = client?.currentUserController().currentUser?.devices.last?.id else {
            return
        }

        client?.currentUserController().removeDevice(id: deviceId) { error in
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

        colors.quotedMessageBackgroundCurrentUser = UIColor(white: 0.0, alpha: 0.05)
        colors.quotedMessageBackgroundOtherUser = UIColor(white: 0.0, alpha: 0.05)
        colors.messageCurrentUserBackground = [UIColor(Color("Purple"))]
        colors.messageOtherUserBackground = [UIColor.white]
        colors.messageCurrentUserTextColor = UIColor.white
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
        minimumSwipeGestureDistance: 40,
        reactionsPlacement: .bottom

    ),
    messagePaddings: MessagePaddings(horizontal: 12),
    dateIndicatorPlacement: .messageList,
    uniqueReactionsEnabled: true,
    markdownSupportEnabled: false
)
