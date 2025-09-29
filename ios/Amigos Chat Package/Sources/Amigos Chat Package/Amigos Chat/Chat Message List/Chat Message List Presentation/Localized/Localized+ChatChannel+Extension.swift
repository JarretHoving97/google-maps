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

        // system messages

        static var attendanceReminderMessage: String {
            NSLocalizedString(
                "attendance_reminder",
                tableName: table,
                bundle: bundle,
                comment: "System message in the community chat"
            )
        }

        static func groupChatCreated(_ value: String) -> String {
            String(
                format: NSLocalizedString(
                    "group_chat_created",
                    tableName: table,
                    bundle: bundle,
                    comment: "System message in the community chat"
                ), value
            )
        }

        static var groupChatJoined: String {
            NSLocalizedString(
                "group_chat_joined",
                tableName: table,
                bundle: bundle,
                comment: "System message in the community chat"
            )
        }

        static var communityShareAdminOnly: String {
            String(
                format: NSLocalizedString(
                    "chat_channel_community_share_admin_only",
                    tableName: table,
                    bundle: bundle,
                    comment: "Banner notificiation in the community channel"
                )
            )
        }
    }
}
