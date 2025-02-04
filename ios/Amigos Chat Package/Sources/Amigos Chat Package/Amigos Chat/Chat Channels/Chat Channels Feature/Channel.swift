//
//  Channel.swift
//  Amigos Chat
//
//  Created by Jarret on 07/01/2025.
//

import Foundation

public struct Channel: Hashable, Equatable {
    public let id: UUID
    public let name: String
    public let imageURL: URL?
    public let unreadCount: Int
    public let lastMessage: DisplayMessage?
}

public struct DisplayMessage: Hashable, Equatable {
    let id: UUID
    let text: String

    public init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}
