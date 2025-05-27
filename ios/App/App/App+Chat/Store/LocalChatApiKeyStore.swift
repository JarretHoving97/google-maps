//
//  LocalChatApiKeyStore.swift
//  App
//
//  Created by Jarret on 01/05/2025.
//

import Amigos_Shared
import Amigos_Chat_Package

/// ApiKey store from `Amigos_Shared` package but conform to `TokenStoreProtocol` from `Amigos_Chat_Package` package.
/// This way modules won't depend on each other.
final class LocalChatApiKeyStore: ChatApiKeyStore, TokenStoreProtocol {}
