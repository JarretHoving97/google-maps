//
//  ChatChannel+LocalProtocol+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/08/2025.
//

import StreamChat

extension ChatChannel: ChatChannelProtocol {

    var id: String {
        cid.description
    }

    var localUnreadCount: any ChannelUnreadCountProtocol {
        LocalChannelUnreadCount(from: unreadCount)
    }

    var localOtherUser: (any ChatChannelMemberProtocol)? {
        LocalChatChannelMember.create(from: otherUser)
    }

    var relatedConceptType: ChatChannelRelatedConceptType {
        if isDirectMessageChannel {
            return .standard
        }

        // Legacy: mixer support for existing data only.
        // TODO: Remove when legacy mixer data is no longer present.
        if let mixerId = extraData["mixerId"]?.stringValue {
            return .mixer(id: mixerId)
        }

        if let communityId = extraData["communityId"]?.stringValue {
            return .community(id: communityId)
        }

        return .activity(id: cid.id)
    }

    var localReads: [any ChannelReadProtocol] {
        reads
    }

    var localLatestMessages: [Message] {
        let messageMapper = MessageMapper()
        return latestMessages.map(messageMapper.map)
    }
}
