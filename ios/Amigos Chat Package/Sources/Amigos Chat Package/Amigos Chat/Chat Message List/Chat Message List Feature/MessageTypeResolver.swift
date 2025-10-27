//
//  MessageTypeResolver.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

public class MessageTypeResolver: AmigosMessageTypeResolving {

    private let message: Message

    public init(message: Message) {
        self.message = message
    }

    public func isDeleted() -> Bool {
        return message.isDeleted
    }

    public func hasImageAttachment() -> Bool {
        return !message.imageAttachments.isEmpty
    }

    public func hasVideoAttachment() -> Bool {
        return !message.videoAttachments.isEmpty
    }

    public func hasLinkAttachment() -> Bool {
        return !message.linkAttachments.isEmpty
    }

    public func hasFileAttachment() -> Bool {
        return !message.fileAttachments.isEmpty
    }

    public func hasCustomAttachment() -> Bool {
        return false
    }

    public func hasUnsupportedAttachment() -> Bool {
        return message.attachments.contains(.notsupported)
    }
}
