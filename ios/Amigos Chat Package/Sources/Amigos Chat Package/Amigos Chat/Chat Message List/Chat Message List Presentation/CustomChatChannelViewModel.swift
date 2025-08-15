//
//  CustomChatChannelViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/08/2025.
//

import Foundation

// Used for just translations now to prevent adding localizations in the Resources folder. This way we will not have conflicts with other open PR's which contains translations.
class CustomChatChannelViewModel {}

extension CustomChatChannelViewModel {

    var createActivityLabel: String {
        return Localized.ChatChannel.createActivityLabel
    }
}
