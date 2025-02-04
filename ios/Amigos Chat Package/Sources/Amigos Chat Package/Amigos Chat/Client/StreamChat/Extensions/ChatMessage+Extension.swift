//
//  ChatMessage+Extension.swift
//  Amigos Chat
//
//  Created by Jarret on 08/01/2025.
//

import Foundation
import StreamChat

extension ChatMessage {
    func toLocal() -> DisplayMessage {
        DisplayMessage(
            id: UUID(uuidString: id) ?? UUID(),
            text: text
        )
    }
}

extension ChatUser: Author {

    public var userId: UUID {
        return UUID(uuidString: id) ?? UUID()
    }
}
