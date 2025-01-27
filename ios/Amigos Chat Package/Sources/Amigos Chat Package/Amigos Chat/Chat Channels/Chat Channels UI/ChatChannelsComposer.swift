//
//  ChatChannelsComposer.swift
//  Amigos Chat
//
//  Created by Jarret on 07/01/2025.
//

import SwiftUI

public class ChatChannelsComposer {

    @MainActor
    public static func compose(with client: any AmigosChatClientProtocol) -> ChannelsListView {

        let viewModel = ChatChannelsViewModel(loader: client.channelListLoader)
        let view = ChannelsListView(viewModel: viewModel)

        return view
    }
}
