//
//  LocalChatApiKeyStore.swift
//  App
//
//  Created by Jarret on 01/05/2025.
//

import Amigos_Shared
import Foundation

/// ApiKey store from `Amigos_Shared` package but conform to `ApiKeyStoreProtocol` current module
final class LocalChatApiKeyStore: ChatApiKeyStore, ApiKeyStoreProtocol {}
