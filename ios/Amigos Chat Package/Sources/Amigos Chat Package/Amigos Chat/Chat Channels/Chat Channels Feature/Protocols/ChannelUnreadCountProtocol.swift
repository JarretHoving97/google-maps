//
//  UnreadCountProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/08/2025.
//

import Foundation

public protocol ChannelUnreadCountProtocol: Equatable {

    var messages: Int { get }

    /// The number of unread messages that mention the current user.
    var mentions: Int { get }
}
