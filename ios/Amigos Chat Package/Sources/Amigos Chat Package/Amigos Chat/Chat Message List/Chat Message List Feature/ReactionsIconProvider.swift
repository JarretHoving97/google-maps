//
//  ReactionsIconProvider.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import SwiftUI

public struct ReactionType: RawRepresentable, Codable, Hashable, ExpressibleByStringLiteral {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: - ExpressibleByStringLiteral

    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            rawValue: try container.decode(String.self)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

class ReactionsIconProvider {

    static private var availableReations: [ReactionType: LocalChatMessageReactionAppearance] = {
        [
            ReactionType(rawValue: "thumbs-up"): LocalChatMessageReaction(emoji: "👍"),
            ReactionType(rawValue: "heart"): LocalChatMessageReaction(emoji: "❤️"),
            ReactionType(rawValue: "tears-of-joy"): LocalChatMessageReaction(emoji: "😂"),
            ReactionType(rawValue: "astonished"): LocalChatMessageReaction(emoji: "😲"),
            ReactionType(rawValue: "cry"): LocalChatMessageReaction(emoji: "😥"),
            ReactionType(rawValue: "pray"): LocalChatMessageReaction(emoji: "🙏"),
            ReactionType(rawValue: "fire"): LocalChatMessageReaction(emoji: "🔥"),
            ReactionType(rawValue: "tada"): LocalChatMessageReaction(emoji: "🎉"),
            ReactionType(rawValue: "thumbsdown"): LocalChatMessageReaction(emoji: "👎"),
            ReactionType(rawValue: "star-struck"): LocalChatMessageReaction(emoji: "🤩"),
            ReactionType(rawValue: "white_check_mark"): LocalChatMessageReaction(emoji: "✅"),
            ReactionType(rawValue: "thinking_face"): LocalChatMessageReaction(emoji: "🤔")
        ]
    }()

    var availableReations: [ReactionType: LocalChatMessageReactionAppearance] {
        return Self.availableReations
    }

    func icon(for reaction: ReactionType) -> UIImage? {
        return Self.availableReations[reaction]?.largeIcon
    }

    func smallIcon(for reaction: ReactionType) -> UIImage? {
        return Self.availableReations[reaction]?.smallIcon
    }

    func emoji(for reaction: ReactionType) -> String? {
        return Self.availableReations[reaction]?.emoji
    }
}

extension ReactionType: Identifiable {
    public var id: String {
        rawValue
    }
}

extension ReactionType {
    var position: Int {
        switch rawValue {
        case "thumbs-up": return 0
        case "heart": return 1
        case "tears-of-joy": return 2
        case "astonished": return 3
        case "sad": return 4
        case "pray": return 5
        case "fire": return 6
        case "tada": return 7
        case "thumbs-down": return 8
        case "star-struck": return 9
        case "check": return 10
        case "thinking": return 11
        default: return 12
        }
    }
}
