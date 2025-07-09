//
//  Stream+ChatMessage+ChatMessageProtocol+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation
import StreamChat

extension ChatMessage: ChatMessageProtocol {

    public var layoutKey: String? {
        if let layoutKey = extraData["layoutKey"]?.stringValue {
            return layoutKey
        }

        return nil
    }

    public var user: any Author {
        author
    }

    public var localQuotedMessage: (any ChatMessageProtocol)? {
        self.quotedMessage
    }

    public var attachments: [any ChatMessageAttachmentProtocol] {
        return allAttachments
    }

    public var sendingState: String? {
        return self.localState?.rawValue
    }

    public var reactions: [String : Int] {
        Dictionary(uniqueKeysWithValues: reactionCounts.map { ($0.key.rawValue, Int($0.value)) })
    }
}
