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
        ReactionType(rawValue: "heart"): LocalChatMessageReaction(emoji: "❤️"),
        ReactionType(rawValue: "tears-of-joy"): LocalChatMessageReaction(emoji: "😂"),
        ReactionType(rawValue: "thumbs-up"): LocalChatMessageReaction(emoji: "👍"),
        ReactionType(rawValue: "astonished"): LocalChatMessageReaction(emoji: "😲"),
        ReactionType(rawValue: "fire"): LocalChatMessageReaction(emoji: "🔥")
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
        case "heart": return 0
        case "tears-of-joy": return 1
        case "thumbs-up": return 2
        case "astonished": return 3
        case "fire": return 4
        default: return 5
        }
    }
}
