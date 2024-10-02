//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import StreamChatSwiftUI

/// Chat channel list item that supports navigating to a destination.
/// It's generic over the channel destination.
public struct CustomChatChannelNavigatableListItem<ChannelDestination: View>: View {
    private var channel: ChatChannel
    private var channelName: String
    private var avatar: UIImage
    private var disabled: Bool
    private var onlineIndicatorShown: Bool
    @Binding private var selectedChannel: ChannelSelectionInfo?
    private var channelDestination: (ChannelSelectionInfo) -> ChannelDestination
    private var onItemTap: (ChatChannel) -> Void
    private var onLongPress: (ChatChannel) -> Void

    init(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        onLongPress: @escaping (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.channelName = channelName
        self.channelDestination = channelDestination
        self.onItemTap = onItemTap
        self.onLongPress = onLongPress
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.disabled = disabled
        _selectedChannel = selectedChannel
    }

    public var body: some View {
        ZStack {
            CustomChatChannelListItemView(
                channel: channel,
                channelName: channelName,
                injectedChannelInfo: injectedChannelInfo,
                avatar: avatar,
                onlineIndicatorShown: false,
                disabled: disabled,
                onItemTap: onItemTap,
                onLongPress: onLongPress
            )

            NavigationLink(
                tag: channel.channelSelectionInfo,
                selection: $selectedChannel
            ) {
                LazyView(channelDestination(channel.channelSelectionInfo))
            } label: {
                EmptyView()
            }
        }
        .id("\(channel.id)-navigatable")
    }

    private var injectedChannelInfo: InjectedChannelInfo? {
        selectedChannel?.channel.cid.rawValue == channel.cid.rawValue ? selectedChannel?.injectedChannelInfo : nil
    }
}
