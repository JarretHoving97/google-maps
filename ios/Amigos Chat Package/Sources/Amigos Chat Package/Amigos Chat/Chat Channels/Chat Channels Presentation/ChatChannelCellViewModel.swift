//
//  ChatChannelCellViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/08/2025.
//

import SwiftUI

@MainActor
class ChatChannelCellViewModel: ObservableObject {

    private let readsForMessageHandler: ReadsForMessageHandler

    let localeSettings: LocaleSettings

    let name: String

    private let receivedChannelImage: UIImage

    var image: AmiImage {
        // return channel imageURL
        if !channel.isDirectMessageChannel {
            return .url(channel.imageURL)
        }

        // return received image from loader
        return .image(receivedChannelImage)
    }

    var subtitle: String {
        return channel.subtitleText ?? ""
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

    var hideUnreadLabel: Bool {
        return channel.localUnreadCount.messages == 0 && channel.localUnreadCount.mentions == 0
    }

    var relatedConceptType: ChatChannelRelatedConceptType {
        return channel.relatedConceptType
    }

    var showReadIndicator: Bool {
        guard let currentUserId = readsForMessageHandler.currentUserId else { return false }
        return channel.localLatestMessages.first?.user.id == currentUserId
    }

    var readIndicatorViewData: ReadIndicatorViewModel {
        return ReadIndicatorViewModel(
            readsForMessageHandler: readsForMessageHandler,
            message: channel.localLatestMessages.first
        )
    }

    private var channel: LocalChannel

    init(
        channel: LocalChannel,
        localeSettings: LocaleSettings = .shared,
        name: String,
        image: UIImage,
        readsForMessageHandler: ReadsForMessageHandler = PlaceholderMessageReadHelper()
    ) {
        self.channel = channel
        self.localeSettings = localeSettings
        self.name = name
        self.receivedChannelImage = image
        self.readsForMessageHandler = readsForMessageHandler
    }
}
