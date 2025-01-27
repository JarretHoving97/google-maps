//
//  ChannelsListView.swift
//  Amigos Chat
//
//  Created by Jarret on 08/01/2025.
//

import SwiftUI

public struct ChannelsListView: View {

    @StateObject private var viewModel: ChatChannelsViewModel

    init(viewModel: ChatChannelsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public  var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.channels, id: \.self) { channel in
                    VStack {
                        HStack(spacing: 10) {
                            Circle()

                            VStack(alignment: .leading) {
                                Text(channel.name)
                                    .lineLimit(1)
                                    .font(.headline)

                                Text(channel.lastMessage?.text ?? "")
                                    .lineLimit(1)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 10)

                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .leading)
                        Divider()
                    }
                    .animation(.easeOut, value: channel)
                }
            }
            .padding(.vertical, 20)

        }
        .onAppear {
            viewModel.loadChannels()
        }
    }
}

#Preview {
    let viewModel = ChatChannelsViewModel()
    viewModel.channels = [
        Channel(
            id: UUID(),
            name: "Luke Skywalker",
            imageURL: nil,
            unreadCount: 4,
            lastMessage: Message(id: UUID(), text: "What's up dog?")
        ),
        Channel(
            id: UUID(),
            name: "Han Solo",
            imageURL: nil,
            unreadCount: 4,
            lastMessage: Message(id: UUID(), text: "I need you now, can you meet me at the bridge?")
        )
    ]

    return ChannelsListView(viewModel: viewModel)
}
