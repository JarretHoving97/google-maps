//
//  ApiKeyStore.swift
//  Amigos_Shared
//
//  Created by Jarret on 01/05/2025.
//

open class ChatApiKeyStore {

    private let keychainHelper = KeychainHelper(
        keychainGroup: KeychainTokenStore.chatTokenStore,
        service: AppGroupNameIdentifiers.amigos
    )
    private let tokenKey = "stream.api.key"

    public init() {}

    public private(set) var apiKey: String? {
        get { keychainHelper.get(tokenKey) }
        set { keychainHelper.set(newValue, forKey: tokenKey) }
    }

    public func set(_ value: String?) {
        self.apiKey = value
    }
}
