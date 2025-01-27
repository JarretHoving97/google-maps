//
//  ChatChannelsViewModel.swift
//  Amigos Chat
//
//  Created by Jarret on 07/01/2025.
//
import SwiftUI

class ChatChannelsViewModel: ObservableObject {

    @Published var channels: [Channel] = []

    var loader: ChannelListLoader?

    private lazy var observer: ChannelListLoader.Observer = { [weak self] channels in
        DispatchQueue.main.async {
            self?.channels = channels
        }
    }

    init(loader: ChannelListLoader? = nil) {
        self.loader = loader
    }

    func loadChannels() {
        loader?.channelsChangesEventObserver = observer
    }
}
