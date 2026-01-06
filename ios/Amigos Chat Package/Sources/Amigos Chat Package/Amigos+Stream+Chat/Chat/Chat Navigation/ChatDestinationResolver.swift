//
//  ChatDestinationResolver.swift
//  Amigos Chat Package
//
//  Created by Jarret on 08/12/2025.
//

import SwiftUI
import StreamChat

public struct ChatDestinationResolver {

    private let client: ChatClient
    private let chatRouteInfoBuilder: ChatRouteInfoBuilder

    public init(
        client: ChatClient,
        chatRouteInfoBuilder: ChatRouteInfoBuilder
    ) {
        self.client = client
        self.chatRouteInfoBuilder = chatRouteInfoBuilder
    }

    @ViewBuilder
    func view(for route: ChatRoute) -> some View {
        switch route {

        case let .conversation(info):

            switch info {
            case let .channel(channel):

                let channelInfo = chatRouteInfoBuilder.channelRouteInfo(
                    channel: channel.cid
                )
                createChannelView(with: channelInfo)

            case let .channelInfo(info):
                if let channelId = try? ChannelId(cid: info.channelId) {
                    let channelInfo = chatRouteInfoBuilder.channelRouteInfo(
                        channel: channelId
                    )
                    createChannelView(with: channelInfo)
                } else {
                    EmptyView()
                }

            }

        case let .thread(viewData):

            if let channelId = try? ChannelId(cid: viewData.channelId) {
                let channelController = client.channelController(for: channelId)

                if let message = channelController.messages.first(where: { $0.id == viewData.messageId }) {
                    let messageController = client.messageController(
                        cid: channelId,
                        messageId: viewData.messageId
                    )

                    let viewModel = MessageThreadChannelViewModel(
                        messageController: messageController,
                        channelController: channelController,
                        pollControllerbuilder: PollBuilderFactory.build(client: client),
                        navigationTitle: channelController.channel?.name ?? ""
                    )

                    MessageThreadChannelView(
                        viewModel: viewModel,
                        messageActonsBuilder: StreamMessageActionService(
                            chatClient: client,
                            channelController: channelController,
                            isInThread: true,
                            message: message
                        )
                    )
                } else {
                    // Could not find message with the specified id
                    EmptyView()
                }
            } else {
                // Invalid channel id
                EmptyView()
            }

        default:
            EmptyView()
        }
    }

    private func createChannelView(with info: ChannelRouteInfo) -> some View {

        return ChatChannelScreen(
            with: info.viewFactory,
            channel: info.controller.channel,
            chatClient: info.client,
            chatChannelController: info.controller,
            viewModel: ChatChannelScreenViewModel(isDirectMessageChannel: info.controller.channel?.isDirectMessageChannel ?? false
            ),
            messageId: info.messageId,
            messageActionsViewBuilder: info.messageActionsViewBuilder
        )
    }
}
