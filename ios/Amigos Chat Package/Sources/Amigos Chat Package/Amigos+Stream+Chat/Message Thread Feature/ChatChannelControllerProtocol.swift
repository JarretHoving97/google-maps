//
//  ChatChannelControllerProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 06/10/2025.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

/// Minimal adapter protocol for StreamChat's ChatChannelController, tailored to the
/// APIs your module currently uses. Keep this surface small and grow it only as needed.
@MainActor
public protocol ChatChannelControllerProtocol: AnyObject {
    // Basic identity and state
    var cid: ChannelId { get }

    var repliedMessage: ChatMessage? { get }

    var localMessages: [ChatMessage] { get }
}

// MARK: - Retroactive conformance

extension ChatMessageController: ChatChannelControllerProtocol {

    private static var mapper: MessageMapper {
        return MessageMapper()
    }

    public var repliedMessage: ChatMessage? {
        return message
    }

    public var localMessages: [ChatMessage] {
        return Array(replies)
    }
}
