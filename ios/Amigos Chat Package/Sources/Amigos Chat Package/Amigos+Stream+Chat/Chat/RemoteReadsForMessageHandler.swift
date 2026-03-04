//
//  RemoteReadsForMessageHandler.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/02/2026.
//

import Foundation
import StreamChat

class RemoteReadsForMessageHandler: ReadsForMessageHandler {

    private let channel: ChatChannel

    let currentUserId: String?

    init(channel: ChatChannel, currentUserId: String?) {
        self.channel = channel
        self.currentUserId = currentUserId
    }

    func readUsers(message: Message?) -> [LocalUser] {
        channel.readUsers(
            currentUser: currentUserId,
            message: message
        )
        .map { LocalUser(id: $0.id, name: $0.name ?? "") }
    }
}
