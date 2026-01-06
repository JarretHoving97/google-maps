//
//  ChannelInfo.swift
//  App
//
//  Created by Jarret on 18/12/2024.
//
import StreamChat

public struct ChannelInfo: Equatable, Hashable {
    public let messageId: String?
    public let channelId: String

    public init(messageId: String? = nil, channelId: String) {
        self.messageId = messageId
        self.channelId = channelId
    }
}

public extension ChannelInfo {
    var streamChannelId: ChannelId? {
        try? ChannelId(cid: channelId)
    }
}
