//
//  StreamChannelListLoader.swift
//  Amigos Chat
//
//  Created by Jarret on 07/01/2025.
//

import StreamChat
import StreamChatSwiftUI

class StreamChannelListLoader: ChannelListLoader {

    var channelsChangesEventObserver: Observer?
    let chatChannelListcontroller: ChatChannelListController

    init(chatChannelListcontroller: ChatChannelListController) {
        self.chatChannelListcontroller = chatChannelListcontroller
        chatChannelListcontroller.delegate = self
    }

    func loadChannels(completion: @escaping ChannelListResult) {
        chatChannelListcontroller.synchronize { [weak self] error in
            guard let self else { return }
            if let error {
                completion(.failure(error))
            } else {
                let remoteChannels = chatChannelListcontroller.channels
                let localChannels = remoteChannels.compactMap { ChatChannelMapper.map(chatChannel: $0) }

                completion(.success(localChannels))
            }
        }
    }
}

extension StreamChannelListLoader: ChatChannelListControllerDelegate {

    func controller(_ controller: ChatChannelListController, didChangeChannels changes: [ListChange<ChatChannel>]) {
        /// it's also possible to animatie things with Streams ListChanges<ChatChannel> objects
        let remoteChannels = chatChannelListcontroller.channels
        let localChannels = remoteChannels.compactMap { ChatChannelMapper.map(chatChannel: $0) }
        channelsChangesEventObserver?(localChannels)
    }
}
