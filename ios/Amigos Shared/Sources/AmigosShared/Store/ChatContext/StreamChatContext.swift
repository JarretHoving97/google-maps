//
//  StreamChatContext.swift
//  Amigos_Shared
//
//  Created by Jarret on 01/05/2025.
//

import Foundation

public class StreamChatContext {

    private let tokenStore: ChatTokenStore
    private let apiKeyStore: ChatApiKeyStore

    public init(
        tokenStore: ChatTokenStore = ChatTokenStore(),
        apiKeyStore: ChatApiKeyStore = ChatApiKeyStore()
    ) {
        self.tokenStore = tokenStore
        self.apiKeyStore = apiKeyStore
    }
}

extension StreamChatContext: ChatContext {

    public var appGroupId: String {
        AppGroupNameIdentifiers.stream
    }

    public var token: String? {
        tokenStore.token
    }

    public var apiKey: String? {
        apiKeyStore.apiKey
    }
}
