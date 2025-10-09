//
//  Utils+Amigos+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

public extension Utils {

    static var amigosUtils: Utils {
        let utils = Utils(
            messageTypeResolver: LocationMessageTypeResolver(),
            commandsConfig: CustomCommandsConfig(),
            messageListConfig: customMessageListConfig,
            composerConfig: ComposerConfig(
                isVoiceRecordingEnabled: true,
                inputViewCornerRadius: 16,
                inputFont: UIFont(name: "Poppins-Regular", size: 14)!,
                inputPaddingsConfig: PaddingsConfig(top: 4, bottom: 4, leading: 4, trailing: 4)
            ),
            pollsConfig: PollsConfig(
                multipleAnswers: .init(configurable: true, defaultValue: false),
                anonymousPoll: .init(configurable: false, defaultValue: false),
                suggestAnOption: .init(configurable: false, defaultValue: false),
                addComments: .init(configurable: false, defaultValue: false),
                maxVotesPerPerson: .init(configurable: true, defaultValue: false)
            ),
            channelHeaderLoader: CustomChannelHeaderLoader()
        )

        utils.sortReactions = amigosSortReactions

        return utils
    }

    static let amigosReactionsOrder: [String] = [
        "thumbs-up",
        "heart",
        "tears-of-joy",
        "astonished",
        "cry",
        "pray",
        "fire",
        "tada",
        "thumbsdown",
        "star-struck",
        "white_check_mark",
        "thinking_face"
    ]

    static let amigosSortReactions: (MessageReactionType, MessageReactionType) -> Bool = { lhs, rhs in
        let order = amigosReactionsOrder

        let lIndex = order.firstIndex(of: lhs.rawValue) ?? Int.max
        let rIndex = order.firstIndex(of: rhs.rawValue) ?? Int.max

        if lIndex != rIndex {
            return lIndex < rIndex
        } else {
            return lhs.rawValue < rhs.rawValue
        }
    }
}
