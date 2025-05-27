//
//  StreanChatClient+ChatClient+Extension.swift
//  App
//
//  Created by Jarret on 01/05/2025.
//

import Amigos_Shared
import StreamChat
import Foundation

extension StreamChatContext {

    var config: ChatClientConfig? {

        guard let apiKey = apiKey else {
            print("API Key is nil, make sure an apiKey is configured")
            return nil
        }
        var config = ChatClientConfig(apiKey: APIKey(apiKey))
        config.applicationGroupIdentifier = appGroupId

        return config
    }

    func createChatClient() -> ChatClient? {
        guard let token, let config else {
            print("Token is nil, make sure the user is logged in to chat")
            return nil
        }

        let client = ChatClient(config: config)
        client.setToken(token: Token(stringLiteral: token))
        return client
    }
}
