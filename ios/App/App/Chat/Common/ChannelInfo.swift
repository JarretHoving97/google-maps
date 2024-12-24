//
//  ChannelInfo.swift
//  App
//
//  Created by Jarret on 18/12/2024.
//
import StreamChat

struct ChannelInfo {
    let messageId: String?
    let channelId: String

    init(messageId: String? = nil, channelId: String) {
        self.messageId = messageId
        self.channelId = channelId
    }
}

extension ChannelInfo {
    var streamChannelId: ChannelId? {
        try? ChannelId(cid: channelId)
    }
}
