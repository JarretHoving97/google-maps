//
//  StreamChatClient.swift
//  Amigos Chat
//
//  Created by Jarret on 06/01/2025.
//

import StreamChatSwiftUI
import StreamChat
import Foundation

// MARK: Connected to Streams DEMO environment for now
/// We need to integrate with our own configuration in the near future.
/// This is currently not possible
/// We need access to some tokenloaders and inject it by abstractions first.
public class StreamChatClient: AmigosChatClientProtocol {

    public typealias loginInfo = UserCredentials

    public typealias Configuration = Config

    public var config: Configuration

    public  var channelListLoader: ChannelListLoader?

    private var chatClient: ChatClient!

    private var streamChat: StreamChat!

    public init(config: Configuration) {
        self.config = config
        var streamClientConfig = ChatClientConfig(apiKey: APIKey(config.apiKey))
        streamClientConfig.isLocalStorageEnabled = config.isLocalStorageEnabled
        streamClientConfig.applicationGroupIdentifier = config.applicationGroupIdentifier
        streamClientConfig.maxAttachmentCountPerMessage = config.maxAttachmentCountPerMessage

        let chatClient = ChatClient(config: streamClientConfig)
        self.streamChat = StreamChat(chatClient: chatClient)

        self.chatClient = chatClient
    }

    public func configure() {

        Task { await login() }

        let controller = chatClient.channelListController(query: .init(
            filter: .containMembers(userIds: [chatClient.currentUserId!])
          ))

        self.channelListLoader = StreamChannelListLoader(chatChannelListcontroller: controller)
    }

    public func login(with loginInfo: UserCredentials) async throws {
        try await chatClient.connectUser(
            userInfo: .init(
                id: loginInfo.id,
                name: loginInfo.name,
                imageURL: loginInfo.avatarURL
            ),
            token: Token(rawValue: loginInfo.token)
        )
    }

    func login() async {
        let guest =  UserCredentials(
            id: "luke_skywalker",
            name: "Luke Skywalker",
            avatarURL: URL(string: "https://profilepictures-dev.amigosapp.nl/public/01aeaaaa-3cc1-4834-82d0-8ae142807ddd.jpg"),
            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibHVrZV9za3l3YWxrZXIifQ.b6EiC8dq2AHk0JPfI-6PN-AM9TVzt8JV-qB1N9kchlI",
            birthLand: "Tatooine"
        )

        do {
            try await login(with: guest)
        } catch {
            print("error occured: \(error.localizedDescription)")
        }
    }
    public struct Config {
        let isLocalStorageEnabled: Bool
        let applicationGroupIdentifier: String
        let maxAttachmentCountPerMessage: Int
        let apiKey: String

        var appearence: Appearance = .default

        public init(isLocalStorageEnabled: Bool, applicationGroupIdentifier: String, maxAttachmentCountPerMessage: Int, apiKey: String, appearence: Appearance = .default) {
            self.isLocalStorageEnabled = isLocalStorageEnabled
            self.applicationGroupIdentifier = applicationGroupIdentifier
            self.maxAttachmentCountPerMessage = maxAttachmentCountPerMessage
            self.apiKey = apiKey
            self.appearence = appearence
        }
    }

    public struct UserCredentials {
        let id: String
        let name: String
        let avatarURL: URL?
        let token: String
        let birthLand: String
    }
}
