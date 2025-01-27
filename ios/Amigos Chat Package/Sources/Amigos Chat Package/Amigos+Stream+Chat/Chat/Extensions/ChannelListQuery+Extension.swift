//
//  ChannelListQuery+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

import StreamChat

public extension ChannelListQuery {

    static func defaultUserListQuery(user: String) -> ChannelListQuery {
        ChannelListQuery(
            filter: .and(
                [
                    .equal(.type, to: .messaging),
                    .containMembers(userIds: [user]),
                    .exists(.lastMessageAt)
                ]
            )
        )
    }
}
