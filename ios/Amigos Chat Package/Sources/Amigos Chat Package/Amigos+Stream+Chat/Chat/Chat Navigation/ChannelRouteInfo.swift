//
//  ChannelRouteInfo.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/12/2025.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

public struct ChannelRouteInfo: Hashable, Equatable {
    let viewFactory: CustomUIFactory
    let controller: ChatChannelController
    let client: ChatClient
    let messageId: String?
    let channelCreationService: ChannelCreationService
    let messageActionsViewBuilder: OnCreateMessageActionsFactory?

    public init(
        viewFactory: CustomUIFactory = CustomUIFactory(),
        controller: ChatChannelController,
        client: ChatClient,
        messageId: String?,
        channelCreationService: ChannelCreationService = MainTheadDispatchDecorator(decoratee: RemoteFindOrCreateChannelService()),
        messageActionsViewBuilder: OnCreateMessageActionsFactory?
    ) {
        self.viewFactory = viewFactory
        self.controller = controller
        self.client = client
        self.messageId = messageId
        self.channelCreationService = channelCreationService
        self.messageActionsViewBuilder = messageActionsViewBuilder
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
        hasher.combine(ObjectIdentifier(viewFactory))
        hasher.combine(ObjectIdentifier(controller))
        hasher.combine(ObjectIdentifier(client))
    }

    public static func == (lhs: ChannelRouteInfo, rhs: ChannelRouteInfo) -> Bool {
        guard lhs.controller.channel == rhs.controller.channel,
              lhs.messageId == rhs.messageId else { return false }
        return true
    }
}
