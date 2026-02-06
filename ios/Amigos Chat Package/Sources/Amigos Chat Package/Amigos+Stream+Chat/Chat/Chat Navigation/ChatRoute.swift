//
//  ChatRoute.swift
//  Amigos Chat Package
//
//  Created by Jarret on 08/12/2025.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

public enum ChatRoute: Hashable, Equatable {

    case conversation(Conversation)
    case thread(MessageThreadChannelViewData)
    case client(ClientRoute)
    case readReceipts(ReadReceiptsViewData)

    // if the client does not needs to track the route to a view return nil.
    var path: String? {
        switch self {
        case .conversation(let conversation):
            return "/channels/\(conversation.id)"
        case let .client(route):
            return route.value
        default:
           return nil
        }
    }
}

extension ChatRoute {
    /// could be two scenarios navigating to a channel
    /// 1. We can navigate to the `ChatChannelInstance`
    /// 2. We don't have a `ChatChannel` instance so we have to query the channel
    public enum Conversation: Hashable, Equatable {
        case channel(ChatChannel)
        case channelInfo(ChannelInfo)

        var id: String {
            switch self {
            case .channel(let chatChannel):
                return chatChannel.id
            case .channelInfo(let channelInfo):
                return channelInfo.channelId
            }
        }
    }
}
