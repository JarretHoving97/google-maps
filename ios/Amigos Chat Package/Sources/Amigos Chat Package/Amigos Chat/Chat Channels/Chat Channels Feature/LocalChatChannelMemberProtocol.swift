//
//  LocalChatChannelMemberProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/08/2025.
//

import Foundation

struct LocalChatChannelMember: ChatChannelMemberProtocol {
    var id: String

    var name: String?

    var imageURL: URL?

    init(id: String, name: String, imageURL: URL?) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }

    init(from abstraction: ChatChannelMemberProtocol) {
        self.id = abstraction.id
        self.name = abstraction.name
        self.imageURL = abstraction.imageURL
    }
}

extension LocalChatChannelMember {

    static func create(from abstraction: ChatChannelMemberProtocol?) -> LocalChatChannelMember? {
        if let abstraction {
            return LocalChatChannelMember(from: abstraction)
        }

        return nil
    }
}
