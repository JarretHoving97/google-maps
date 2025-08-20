//
//  LocalUnreadCount.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/08/2025.
//

import Foundation

/// A struct describing unread counts for a channel.
public struct LocalChannelUnreadCount: ChannelUnreadCountProtocol {
    /// The default value representing no unread messages.
    public static let noUnread = LocalChannelUnreadCount(messages: 0, mentions: 0)

    /// The total number of unread messages in the channel.
    public let messages: Int

    /// The number of unread messages that mention the current user.
    public let mentions: Int

    public init(messages: Int, mentions: Int) {
        self.messages = messages
        self.mentions = mentions
    }
}

extension LocalChannelUnreadCount {

    public init(from abstraction: any ChannelUnreadCountProtocol) {
        self.messages = abstraction.messages
        self.mentions = abstraction.mentions
    }
}
