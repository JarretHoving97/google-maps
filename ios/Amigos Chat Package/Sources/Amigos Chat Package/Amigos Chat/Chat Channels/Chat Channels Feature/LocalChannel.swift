//
//  LocalChannel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/08/2025.
//

import Foundation

import StreamChat

extension ChatChannelRead: ChannelReadProtocol {

    public var localUser: LocalUser {
        user.toLocal()
    }
}

public protocol ChannelReadProtocol: Equatable {

    var lastReadAt: Date { get }

    var lastReadMessageId: String? { get }

    var unreadMessagesCount: Int { get }

    var localUser: LocalUser { get } // TODO: change protocol name
}

struct LocalChannelRead: ChannelReadProtocol {

    var lastReadAt: Date

    var lastReadMessageId: String?

    var unreadMessagesCount: Int

    var localUser: LocalUser
}

struct LocalChannel: ChatChannelProtocol {

    let id: String

    let name: String?

    let imageURL: URL?

    let localUnreadCount: any ChannelUnreadCountProtocol

    var subtitleText: String?

    let lastMessageAt: Date?

    var relatedConceptType: ChatChannelRelatedConceptType

    var localOtherUser: (any ChatChannelMemberProtocol)?

    var localReads: [any ChannelReadProtocol]

    var localLatestMessages: [Message]

    var memberCount: Int

    init(
        id: String,
        name: String,
        imageURL: URL?,
        lastMessageAt: Date?,
        unreadCount: any ChannelUnreadCountProtocol = LocalChannelUnreadCount.noUnread,
        subtitleText: String?,
        relatedConceptType: ChatChannelRelatedConceptType = .community(id: ""),
        otherUser: ChatChannelMemberProtocol? = nil,
        reads: [any ChannelReadProtocol] = [],
        latestMessages: [Message] = [],
        memberCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.lastMessageAt = lastMessageAt
        self.localUnreadCount = unreadCount
        self.subtitleText = subtitleText
        self.relatedConceptType = relatedConceptType
        self.localOtherUser = otherUser
        self.localReads = reads
        self.localLatestMessages = latestMessages
        self.memberCount = memberCount
    }

    init(from abstraction: ChatChannelProtocol) {
        self.id = abstraction.id
        self.name = abstraction.name
        self.imageURL = abstraction.imageURL
        self.lastMessageAt = abstraction.lastMessageAt
        self.localUnreadCount = abstraction.localUnreadCount
        self.subtitleText = abstraction.subtitleText
        self.relatedConceptType = abstraction.relatedConceptType
        self.localOtherUser = abstraction.localOtherUser
        self.localReads = abstraction.localReads
        self.localLatestMessages = abstraction.localLatestMessages
        self.memberCount = abstraction.memberCount
    }
}

extension LocalChannel {
    public var isDirectMessageChannel: Bool { id.hasPrefix("messaging:!members") }
}
