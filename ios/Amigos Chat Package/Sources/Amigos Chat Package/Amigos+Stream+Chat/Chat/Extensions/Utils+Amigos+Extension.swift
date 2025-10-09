//
//  Utils+Amigos+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

import SwiftUI
import StreamChatSwiftUI

public extension Utils {
    static var amigosUtils: Utils {
        Utils(
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
    }
}
