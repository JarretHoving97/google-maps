//
//  ChatChannelProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/08/2025.
//

import Foundation

protocol ChatChannelProtocol {
    var id: String { get }
    var name: String? { get }
    var imageURL: URL? { get }
    var localUnreadCount: any ChannelUnreadCountProtocol { get }
    var subtitleText: String? { get }
    var relatedConceptType: ChatChannelRelatedConceptType { get }
    var localOtherUser: ChatChannelMemberProtocol? { get }
    var lastMessageAt: Date? { get }
    var localReads: [any ChannelReadProtocol] { get }
    var localLatestMessages: [Message] { get }
    var memberCount: Int { get }
}
