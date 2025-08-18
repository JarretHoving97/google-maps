//
//  ChatChannelCellViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/08/2025.
//

import SwiftUI

class ChatChannelCellViewModel: ObservableObject {

    let localeSettings: LocaleSettings

    let currentUserId: String?

    var name: String {
        // check if DM
        if relatedConceptType == .standard {
            return channel.localOtherUser?.name ?? "Unknown"
        }

        return channel.name ?? "Unknown"
    }

    var subtitle: String {
        return channel.subtitleText ?? ""
    }

    var imageUrl: URL? {
        // check if DM
        if relatedConceptType == .standard {
            return channel.localOtherUser?.imageURL
        }

        return channel.imageURL
    }

    var lastMessageDate: String? {
        guard let lastMessageDate = channel.lastMessageAt else { return nil }
        return formatRelative(date: lastMessageDate, locale: localeSettings.locale)
    }

    var unreadLabel: String {
        channel.localUnreadCount.messages > 99 ? "99+" : "\(channel.localUnreadCount.messages)"
    }

    var unreadMentions: Int {
        return channel.localUnreadCount.mentions
    }

    var unreadMessages: Int {
        return channel.localUnreadCount.messages
    }

    var isRead: Bool {
        return channel.localUnreadCount.messages == 0 && channel.localUnreadCount.mentions == 0
    }

    var relatedConceptType: ChatChannelRelatedConceptType {
        return channel.relatedConceptType
    }

    var showReadIndicator: Bool {
        guard let currentUserId else { return false }
        return channel.localLatestMessages.first?.user.id == UUID(uuidString: currentUserId)
    }

    var readIndicatorViewData: ReadIndicatorViewModel {

        return ReadIndicatorViewModel(
            isRead: isRead,
            isReadByAll: isReadByAll,
            localState: channel.localLatestMessages.last?.localState,
            memberCount: channel.memberCount
        )
    }

    private var isReadByAll: Bool {
        let readUsers = channel.readUsers(currentUser: currentUserId, message: channel.localLatestMessages.first)
        return channel.memberCount <= readUsers.count
    }

    private var channel: LocalChannel

    init(
        channel: LocalChannel,
        currentUserId: String? = nil,
        localeSettings: LocaleSettings = .shared
    ) {
        self.channel = channel
        self.currentUserId = currentUserId
        self.localeSettings = localeSettings
    }
}
