//
//  TokenStoreProtocol.swift
//  App
//
//  Created by Jarret on 01/05/2025.
//


import Amigos_Chat_Package
import Amigos_Shared

/// Token store from `Amigos_Shared` package but conform to `TokenStoreProtocol` from `Amigos_Chat_Package` package.
/// This way modules won't depend on each other.
final class LocalChatJWTtokenStore: ChatTokenStore, TokenStoreProtocol {}
