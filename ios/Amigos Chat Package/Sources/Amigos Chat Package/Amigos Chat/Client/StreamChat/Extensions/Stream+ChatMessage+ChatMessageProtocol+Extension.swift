//
//  Stream+ChatMessage+ChatMessageProtocol+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation
import StreamChat

extension ChatMessage: ChatMessageProtocol {

    public var user: any Author {
        author
    }

    public var localQuotedMessage: (any ChatMessageProtocol)? {
        self.quotedMessage
    }

    public var attachments: [any ChatMessageAttachmentProtocol] {
        return allAttachments
    }
}
