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
    public let lastMessage: Message?
}

public struct Message: Hashable, Equatable {
    public let id: UUID
    public let text: String
}
