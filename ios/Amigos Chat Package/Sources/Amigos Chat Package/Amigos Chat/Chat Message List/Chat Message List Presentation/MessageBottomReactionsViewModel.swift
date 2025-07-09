//
//  MessageBottomReactionsViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 07/03/2025.
//

import SwiftUI

class MessageBottomReactionsViewModel {

    struct Reaction: Identifiable {
        let id = UUID()
        let position: Int
        let icon: String
        let count: Int
    }

    private let iconProvider = ReactionsIconProvider()
    private let reactionsData: [ReactionType: Int]

    @Published private(set) var reactions: [Reaction] = []

    init(reactions: [ReactionType: Int]) {
        self.reactionsData = reactions
        self.reactions = reactionsData.compactMap { key, value in
            guard let icon = iconProvider.emoji(for: key) else { return nil }
            return Reaction(position: key.position, icon: icon, count: value)
        }
        .sorted(by: {$0.position < $1.position})
    }
}
