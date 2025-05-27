//
//  TokenStore.swift
//  Amigos_Shared
//
//  Created by Jarret on 01/05/2025.
//

import Foundation

open class ChatTokenStore {

    private let keychainHelper = KeychainHelper(
        keychainGroup: KeychainTokenStore.chatTokenStore,
        service: AppGroupNameIdentifiers.amigos
    )
    private let tokenKey = "stream.chat.token"

    public init() {}

    public private(set) var token: String? {
        get { keychainHelper.get(tokenKey) }
        set { keychainHelper.set(newValue, forKey: tokenKey) }
    }

    public func set(_ value: String?) {
        self.token = value
    }
}
