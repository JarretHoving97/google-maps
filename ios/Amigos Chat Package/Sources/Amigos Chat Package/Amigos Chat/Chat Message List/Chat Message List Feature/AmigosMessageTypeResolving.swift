//
//  AmigosMessageTypeResolving.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

/// Our own abstraction of StreamChats: `MessageTypeResolving`
/// This reduces risks for breaking changes in updates and decouple it completely from
/// StreamChat.
public protocol AmigosMessageTypeResolving {

    func isDeleted() -> Bool

    func hasImageAttachment() -> Bool

    func hasVideoAttachment() -> Bool

    func hasLinkAttachment() -> Bool

    func hasFileAttachment() -> Bool

    func hasCustomAttachment() -> Bool

    func hasUnsupportedAttachment() -> Bool
}
