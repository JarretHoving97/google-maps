//
//  ChannelControllers.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

import StreamChat

/// can set controllers globally.
/// Used for existing UI components of stream as there is to much work to do DI
class ChatControllers {
    static private(set) var client: ChatClient!
    static private(set) var channelListController: ChatChannelListController?

    private init() {}

    static func configureClient(client: ChatClient) {
        self.client = client

        if let userId = client.currentUserId {
            set(query: .defaultUserListQuery(user: userId))
        }
    }

    @discardableResult
    static func set(query: ChannelListQuery) -> ChatChannelListController {
        self.channelListController = client.channelListController(query: query)
        self.channelListController?.synchronize()
        return channelListController!
    }

    static func remove() {
        self.channelListController = nil
    }
}
