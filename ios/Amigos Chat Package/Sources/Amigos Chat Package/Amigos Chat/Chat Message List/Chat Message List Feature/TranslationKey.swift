//
//  TranslationKey.swift
//  
//
//  Created by Jarret on 18/08/2025.
//

import Foundation

public enum TranslationKey: String {
    case attendanceReminder = "attendance_reminder"
    case groupChatCreated = "group_chat_created"
    case groupChatJoined = "group_chat_joined"
    /* case communityChatCreated = "community_chat_created" */

    /// Returns the localized string for the case.
    /// - Parameter value: The value that replaces the `@%` placeholder.
    /// - Returns: A localized string with the placeholder replaced.
    func localizedString(_ value: String) -> String {
        switch self {
        case .attendanceReminder:
            Localized.ChatChannel.attendanceReminderMessage

        case .groupChatCreated:
            Localized.ChatChannel.groupChatCreated(value)

        case .groupChatJoined:
            Localized.ChatChannel.groupChatJoined
        }
    }
}
