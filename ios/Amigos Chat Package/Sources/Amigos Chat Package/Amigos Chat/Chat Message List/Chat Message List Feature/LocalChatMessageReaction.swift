//
//  LocalChatMessageReaction.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import SwiftUI

protocol LocalChatMessageReactionAppearance {
    var smallIcon: UIImage { get }
    var largeIcon: UIImage { get }
    var emoji: String { get }
}

struct LocalChatMessageReaction: LocalChatMessageReactionAppearance {
    public let smallIcon: UIImage
    public let largeIcon: UIImage
    public let emoji: String

    public init(
        emoji: String
    ) {
        self.emoji = emoji
        self.smallIcon = EmojiImageHelper.toImage(from: emoji, size: 64)
        self.largeIcon = EmojiImageHelper.toImage(from: emoji, size: 256)
    }
}
