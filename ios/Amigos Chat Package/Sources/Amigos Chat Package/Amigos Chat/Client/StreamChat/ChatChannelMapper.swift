//
//  ChatChannelMapper.swift
//  Amigos Chat
//
//  Created by Jarret on 08/01/2025.
//

import Foundation
import StreamChat

/// Maps Stream API's channels to our own channel type
/// Here we can also define custom logic if we wan't different behaviour based of the data given.
enum ChatChannelMapper {

    static private var namer: ChatChannelNamer = defaultChatChannelNamer()

    static func map(channels: [ChatChannel]) -> [Channel] {
        channels.map {
            Channel(
                id: UUID(uuidString: $0.id)!,
                name: $0.name ?? "",
                imageURL: $0.imageURL,
                unreadCount: $0.unreadCount.messages,
                lastMessage: $0.latestMessages.first?.toLocal()
            )
        }
    }

    static func map(chatChannel: ChatChannel) -> Channel {
        Channel(
            id: UUID(uuidString: chatChannel.id) ?? UUID(),
            name: namer(chatChannel, nil) ?? "",
            imageURL: chatChannel.imageURL,
            unreadCount: chatChannel.unreadCount.messages,
            lastMessage: chatChannel.latestMessages.first?.toLocal()
        )
    }
}
