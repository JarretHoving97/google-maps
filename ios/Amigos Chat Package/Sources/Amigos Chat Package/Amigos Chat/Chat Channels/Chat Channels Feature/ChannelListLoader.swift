//
//  ChannelListLoader.swift
//  Amigos Chat
//
//  Created by Jarret on 07/01/2025.
//

public protocol ChannelListLoader {
    typealias ChannelListResult = (Result<[Channel], Error>) -> Void
    typealias Observer = (([Channel]) -> Void)

    var channelsChangesEventObserver: Observer? { get set }
    func loadChannels(completion: @escaping ChannelListResult)
}
