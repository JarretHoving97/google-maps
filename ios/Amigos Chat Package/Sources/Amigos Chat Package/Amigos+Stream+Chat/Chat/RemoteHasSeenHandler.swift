//
//  RemoteIsReadHandler.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/06/2025.
//

import Foundation
import StreamChat

struct RemoteHasSeenHandler: HasSeenHandler {

    let channel: ChatChannel
    let userId: String?

    func hasSeen(for message: any ChatMessageProtocol) -> Bool {
        let mapper = MessageMapper()
        return hasSeen(for: mapper.map(message))
    }

    func hasSeen(for message: Message) -> Bool {
        guard let userId else { return false }
        let readUsers = channel.readUsers(currentUser: userId, message: message)
        return readUsers.contains(where: { $0.id == userId })
    }
}
