//
//  ChatMessage+Extension.swift
//  Amigos Chat
//
//  Created by Jarret on 08/01/2025.
//

import Foundation
import StreamChat

extension ChatMessage {
    func toLocal() -> Message {
        Message(id: UUID(uuidString: id) ?? UUID(), text: text)
    }
}
