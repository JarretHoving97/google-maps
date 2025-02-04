//
//  MessageTypeResolverStub.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

// swiftlint:disable identifier_name
import Foundation
import Amigos_Chat_Package

class MessageTypeResolverStub: AmigosMessageTypeResolving {

    let _isDeleted: Bool
    let _hasImageAttachment: Bool
    let _hasVideoAttachment: Bool
    let _hasFileAttachment: Bool
    let _hasLinkAttachment: Bool
    let _hasCustomAttachment: Bool

    init(
        isDeleted: Bool = false,
        hasImageAttachment: Bool = false,
        hasFileAttachment: Bool = false,
        hasVideoAttachment: Bool = false,
        hasLinkAttachment: Bool = false,
        hasCustomAttachment: Bool = false
    ) {
        self._isDeleted = isDeleted
        self._hasImageAttachment = hasImageAttachment
        self._hasFileAttachment = hasFileAttachment
        self._hasVideoAttachment = hasVideoAttachment
        self._hasLinkAttachment = hasLinkAttachment
        self._hasCustomAttachment = hasCustomAttachment
    }

    func isDeleted() -> Bool {
        _isDeleted
    }

    func hasImageAttachment() -> Bool {
        _hasImageAttachment
    }

    func hasVideoAttachment() -> Bool {
        _hasVideoAttachment
    }

    func hasLinkAttachment() -> Bool {
        _hasLinkAttachment
    }

    func hasFileAttachment() -> Bool {
        _hasFileAttachment
    }

    func hasCustomAttachment() -> Bool {
        _hasCustomAttachment
    }
}
