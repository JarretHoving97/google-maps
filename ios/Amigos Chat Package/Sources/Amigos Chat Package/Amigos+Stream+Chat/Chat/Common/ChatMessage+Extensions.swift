import StreamChat
import SwiftUI

extension ChatMessage {

    var alignmentInBubble: HorizontalAlignment {
        .leading
    }

    var reactionScoresId: String {
        var output = ""

        if reactionScores.isEmpty {
            return output
        }
        let sorted = reactionScores.keys.sorted { type1, type2 in
            type1.id > type2.id
        }
        for key in sorted {
            let score = reactionScores[key] ?? 0
            output += "\(key.rawValue)\(score)"
        }

        return output
    }
}
