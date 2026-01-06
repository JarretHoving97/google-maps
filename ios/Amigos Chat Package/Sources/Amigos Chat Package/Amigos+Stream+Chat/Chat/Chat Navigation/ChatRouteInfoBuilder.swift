//
//  ChatRouteInfoBuilder.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/12/2025.
//

import Foundation
import StreamChat

public class ChatRouteInfoBuilder {

    private let client: ChatClient
    private let viewFactory: CustomUIFactory

    public init(
        client: ChatClient,
        viewFactory: CustomUIFactory = CustomUIFactory()
    ) {
        self.client = client
        self.viewFactory = viewFactory
    }

    public func channelRouteInfo(
        channel: ChannelId,
    ) -> ChannelRouteInfo {

        let controller = client.channelController(for: channel)

        return ChannelRouteInfo(
            controller: controller,
            client: client,
            messageId: nil,
            messageActionsViewBuilder: adaptOnMessageActionsView()
        )
    }

    private func adaptOnMessageActionsView() -> OnCreateMessageActionsFactory? {

        return { [weak self] info in
            guard let self else { return nil }

            guard let channelId = info.message.cid else { return nil }
            return StreamMessageActionService(
                chatClient: client,
                channelController: client.channelController(for: channelId),
                isInThread: info.isInthread,
                message: info.message
            )
        }
    }
}
