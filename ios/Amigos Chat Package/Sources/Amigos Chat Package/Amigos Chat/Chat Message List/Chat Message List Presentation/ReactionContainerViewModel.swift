//
//  ReactionContainerViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import Foundation
import UIKit.UIImage

class ReactionsContainerViewModel {

    let message: Message
    let reactionsProvider: ReactionsIconProvider

    var reactions: [ReactionType] {
        reactionsProvider.availableReations.keys
            .map { $0 }
            .sorted(by: defaultSortReactions)
    }

    init(message: Message, reactionsProvider: ReactionsIconProvider = ReactionsIconProvider()) {
        self.message = message
        self.reactionsProvider = reactionsProvider
    }

    private var defaultSortReactions: (ReactionType, ReactionType) -> Bool {
        { $0.rawValue < $1.rawValue }
    }

    func getIcon(for reaction: ReactionType) -> UIImage? {
        reactionsProvider.availableReations[reaction]?.largeIcon
    }

    func index(for reaction: ReactionType) -> Int? {
        let index = reactions.firstIndex(where: { type in
            type == reaction
        })

        return index
    }
}
