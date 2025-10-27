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

        static var createActivityActionLabel: String {
            NSLocalizedString(
                "message_action_create_activity_title",
                tableName: table,
                bundle: bundle,
                comment: "Button that will appear at the bottom of a chat message"
            )
        }

        static var repeatActivityActionLabel: String {
            NSLocalizedString(
                "message_action_repeat_activity_title",
                tableName: table,
                bundle: bundle,
                comment: "Button that will appear at the bottom of a chat message"
            )
        }

        static var viewActivityActionLabel: String {
            NSLocalizedString(
                "message_action_view_activity_title",
                tableName: table,
                bundle: bundle,
                comment: "Button that will appear at the bottom of a chat message"
            )
        }

        static var viewActionLabel: String {
            NSLocalizedString(
                "message_action_view_title",
                tableName: table,
                bundle: bundle,
                comment: "Button that will appear at the bottom of a chat message"
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

        static var repeatActivity: String {
            NSLocalizedString(
                "repeat_activity",
                tableName: table,
                bundle: bundle,
                comment: "System message in the chat"
            )
        }

        // Unsupported attachments

        static var unsupportedAttachmentOnCurrentOS: String {
            NSLocalizedString(
                "chat_message_attachment_unsupported_os",
                tableName: table,
                bundle: bundle,
                comment: "Unsupported attachment view in chat message for current OS version"
            )
        }

        static var unsupportedAttachmentRequiresAppUpdate: String {
            NSLocalizedString(
                "chat_message_attachment_unsupported_app_update",
                tableName: table,
                bundle: bundle,
                comment: "Unsupported attachment view in chat message that requires app update"
            )
        }

        static var unsupportedAttachmentOpenAppStore: String {
            NSLocalizedString(
                "chat_message_attachment_unsupported_open_app_store",
                tableName: table,
                bundle: bundle,
                comment: "Unsupported attachment view in chat message with action to open App Store"
            )
        }

        // notices

        static var communityAdminOnlyNotice: String {
            String(
                format: NSLocalizedString(
                    "chat_channel_community_admin_only_notice",
                    tableName: table,
                    bundle: bundle,
                    comment: "Banner notificiation in the community channel"
                )
            )
        }
    }
}
