//
//  Untitled.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/08/2025.
//

import Foundation

extension Localized {

    enum ChatChannel {

        static var table: String { "ChatChannel" }

        static var createActivityLabel: String {
            NSLocalizedString(
                "chat_channel_create_activity",
                tableName: table,
                bundle: bundle,
                comment: "Header button displayed in a channel to create an activity including the channel members"
            )
        }

        static var viewCommunityActionLabel: String {
            NSLocalizedString(
                "custom_channel_action_community_title",
                tableName: table,
                bundle: bundle,
                comment: "action button dat will appear when user taps on channel actions"
            )
        }
    }
}
