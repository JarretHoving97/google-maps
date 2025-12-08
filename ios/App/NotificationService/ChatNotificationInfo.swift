//
//  NotificationInfo.swift
//  App
//
//  Created by Jarret on 05/12/2025.
//

import Foundation
import StreamChat

struct ChatNotificationInfo {
    let channelId: String
    let imageURL: URL?
    let title: String
    let body: String
    let author: ChatUser
    let isAnonymous: Bool
    let members: [ChatChannelMember]

    init(
        channelId: String,
        imageURL: URL?,
        title: String,
        body: String,
        author: ChatUser,
        isAnonymous: Bool,
        members: [ChatChannelMember]
    ) {
        self.channelId = channelId
        self.imageURL = imageURL
        self.title = title
        self.body = body
        self.author = author
        self.isAnonymous = isAnonymous
        self.members = members
    }
}
