//
//  ChatMessageMapper.swift
//  Amigos Chat
//
//  Created by Jarret on 08/01/2025.
//

import Foundation
import StreamChat

enum ChatMessageMapper {
    static func map(messages: [ChatMessage]) -> [DisplayMessage] {
        messages.map { $0.toLocal() }
    }
}
