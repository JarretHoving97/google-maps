//
//  ChatMessage+Extension.swift
//  App
//
//  Created by Jarret on 23/05/2025.
//

import Foundation
import StreamChat

extension ChatMessage {

    public func attachmentPreviewText() -> String {

        guard let attachment = allAttachments.first else {
            return text
        }

        switch attachment.type {

        case .image:

            return text.isEmpty ? "📷" : "📷 \(text)"

        case .video:
            return text.isEmpty ? "📹" : "📹 \(text)"

        case .location:
            return text.isEmpty ? "📍" : "📍 \(text)"

        default:
            return text
        }
    }
}
