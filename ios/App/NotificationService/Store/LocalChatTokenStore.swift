//
//  ChatTokenStore.swift
//  App
//
//  Created by Jarret on 01/05/2025.
//

import Amigos_Shared

/// Token store from `Amigos_Shared` package but conform to `TokenStoreProtocol` current module
final class LocalChatTokenStore: ChatTokenStore, TokenStoreProtocol {}
