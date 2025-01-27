//
//  ChatClient.swift
//  Amigos Chat
//
//  Created by Jarret on 07/01/2025.
//

public protocol AmigosChatClientProtocol {

    associatedtype Configuration
    associatedtype loginInfo

    var channelListLoader: ChannelListLoader? { get }

    var config: Configuration { get }
    
    func login(with loginInfo: loginInfo) async throws
}
