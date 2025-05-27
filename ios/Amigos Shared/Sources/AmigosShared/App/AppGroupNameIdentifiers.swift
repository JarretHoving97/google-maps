//
//  AppGroupNameIdentifiers.swift
//  Amigos_Shared
//
//  Created by Jarret on 01/05/2025.
//

import Foundation

/// all the app group identifiers
/// these are used to access shared data between the app and the extension
/// these are used in the app group capabilities
/// `amigosGetStream` is used to access data with `Get Stream`
/// `amigos` is used to access data with `Amigos` app
public enum AppGroupNameIdentifiers {
    static let stream = "group.com.whoisup.app.stream"
    static let amigos = "group.com.whoisup.app"
}

public enum KeychainTokenStore {
    /// Requires a `Team ID` prefix accourding to the docs:
    /// https://developer.apple.com/documentation/security/sharing-access-to-keychain-items-among-a-collection-of-apps
    static let chatTokenStore = "G3578K4W58.com.amigos.chatTokenStore"
}
