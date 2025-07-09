import Foundation
import SwiftUI
import StreamChat
import StreamChatSwiftUI

public class AmigosChatClient: AmigosChatClientProtocol {

    enum AmigosClientError: Swift.Error {
        case implementationFailed
        case unauthenticated
    }

    /// For sharing current jwt token across modules
    /// used for `NotificationService` etc.
    private var jwtTokenStore: TokenStoreProtocol?

    /// For sharing current api token across modules
    /// used for `NotificationService` etc.
    private var apiKeyStore: TokenStoreProtocol?

    public let userStore = UserStore(suiteName: "amigos.chat.user")

    public typealias loginInfo = LoginInfo

    public var config: Config

    public private(set) var chatClient: ChatClient?

    private var streamChat: StreamChat?

    private var currentUserController: CurrentChatUserController?

    public var channelListLoader: ChannelListLoader?

    private let tokenProvider: TokenProvider

    private let pushConfig: ChatPushConfig

    private let userDelegate: CurrentChatUserControllerDelegate

    public var isConfigured: Bool {
        ChatControllers.channelListController != nil
    }

    public init(
        config: Config,
        tokenProvider: TokenProvider,
        pushConfig: ChatPushConfig,
        userDelegate: CurrentChatUserControllerDelegate,
        keychainLoader: KeychainLoader,
        jwtTokenStore: TokenStoreProtocol? = nil,
        apiKeyStore: TokenStoreProtocol? = nil
    ) {
        self.config = config
        self.tokenProvider = tokenProvider
        self.jwtTokenStore = jwtTokenStore
        self.apiKeyStore = apiKeyStore
        self.pushConfig = pushConfig
        self.userDelegate = userDelegate
        /// initialze client
        var streamClientConfig = ChatClientConfig(apiKey: APIKey(config.apiKey))
        streamClientConfig.isLocalStorageEnabled = config.isLocalStorageEnabled
        streamClientConfig.applicationGroupIdentifier = config.applicationGroupIdentifier
        streamClientConfig.maxAttachmentCountPerMessage = config.maxAttachmentCountPerMessage

        let chatClient = ChatClient(config: streamClientConfig)

        self.streamChat = StreamChat(
            chatClient: chatClient,
            appearance: config.appearence,
            utils: .amigosUtils
        )

        self.chatClient = chatClient

        /// set shared controllers
        CurrentEnvironment.set(
            apiUrl: URL(string: config.environment.amigosApiUrl)!,
            url: (URL(string: config.environment.env)!)
        )
        
        KeychainController.setJwtLoader(keychainLoader)
        ChatControllers.configureClient(client: chatClient)

        // store api key in shared module
        apiKeyStore?.set(config.apiKey)
    }

    func verifyUserStore(userId: String) -> Bool {
        guard let token = KeychainController.jwtLoader?.getValueFromKeychain(key: "jwt") else {
            return false
        }

        let jwt = JWT(token: token)

        return jwt.sub == userId
    }

    public func ensureAuthentication() async throws {
        guard chatClient?.currentUserId == nil else {
            // We are logged in, all good.
            return
        }

        guard let userData = userStore.retrieve(), verifyUserStore(userId: userData.id) else {
            // The cache is empty or either invalid.
            return
        }

        try await login(
            with: LoginInfo(
                id: userData.id,
                name: userData.name,
                imageUrl: URL(string: userData.imageUrl)
            )
        )
    }

    /// login and start receiving events and loaders
    public func login(with info: LoginInfo) async throws {
        guard let chatClient else {
            throw AmigosClientError.implementationFailed
        }

        try await chatClient.connectUser(
            userInfo: UserInfo(
                id: info.id,
                name: info.name,
                imageURL: info.imageUrl
            ),
            tokenProvider: streamTokenProvider()
        )

        guard let user = chatClient.currentUserId else {
            throw AmigosClientError.unauthenticated
        }

        userStore.store(
            info: .init(
                id: info.id,
                imageUrl: info.imageUrl?.absoluteString ?? "",
                name: info.name
            )
        )

        /// setup user controller
        let userController = chatClient.currentUserController()
        chatClient.currentUserController().delegate = userDelegate

        userController.delegate = userDelegate

        self.currentUserController = userController
        self.currentUserController?.synchronize()

        /// setup channels loader
        ChatControllers.configureClient(client: chatClient)

        /// push permissions:
        try await UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge])

        await UIApplication.shared.registerForRemoteNotifications()

        /// set global instances for StreamUI
        UserProvider.shared.set(userId: user)
    }

    public func logout() async {
        pushConfig.removeDeviceToken()
        await chatClient?.logout()
        userStore.clear()
    }

    public func addDeviceToken(_ token: String) {
        pushConfig.addDeviceToken(deviceToken: token)
    }

    private func streamTokenProvider() -> (@escaping (Result<Token, Error>) -> Void) -> Void {
        return { [weak self, jwtTokenStore] completion in
            self?.tokenProvider.loadToken { result in
                let mappedResult = result.flatMap { localToken in
                    Result {
                        let streamToken = try localToken.toStreamChatToken()
                        jwtTokenStore?.set(streamToken.rawValue) // Store the token
                        return streamToken
                    }
                }

                if case .failure = mappedResult {
                    jwtTokenStore?.set(nil) // Clear the token on failure
                }

                completion(mappedResult)
            }
        }
    }
}

public protocol ChatPushConfig {
    func addDeviceToken(deviceToken: String)
    func removeDeviceToken()
}

// MARK: Other modules
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
    scrollingAnchor: .center,
    uniqueReactionsEnabled: true,
    markdownSupportEnabled: false
)

extension MessageListConfig {
    var local: MessageListDisplayConfiguration {
        return MessageListDisplayConfiguration(
            messageDisplayOptions: messageDisplayOptions.local
        )
    }
}

extension MessageDisplayOptions {
    var local: LocalMessageDisplayOptions {
        return LocalMessageDisplayOptions(dateLabelSize: dateLabelSize)
    }
}
