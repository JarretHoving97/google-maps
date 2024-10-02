import StreamChat
import SwiftUI
import StreamChatSwiftUI

/// View for the channel list item.
public struct CustomChatChannelListItemView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient
    
    @ObservedObject var localeSettings = LocaleSettings.shared

    var channel: ChatChannel
    var channelName: String
    var injectedChannelInfo: InjectedChannelInfo?
    var avatar: UIImage
    var onlineIndicatorShown: Bool
    var disabled = false
    var onItemTap: (ChatChannel) -> Void
    var onLongPress: (ChatChannel) -> Void

    public init(
        channel: ChatChannel,
        channelName: String,
        injectedChannelInfo: InjectedChannelInfo? = nil,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        onItemTap: @escaping (ChatChannel) -> Void,
        onLongPress: @escaping (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.channelName = channelName
        self.injectedChannelInfo = injectedChannelInfo
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.disabled = disabled
        self.onItemTap = onItemTap
        self.onLongPress = onLongPress
    }
    
    private var isRead: Bool {
        return channel.unreadCount == .noUnread
    }
    
    private var isReadByAll: Bool {
        let readUsers = channel.readUsers(
            currentUserId: chatClient.currentUserId,
            message: channel.latestMessages.first
        )

        return channel.memberCount <= readUsers.count
    }
    
    private var channelActivityImageUrl: URL? {
        if let imageURL = channel.imageURL {
            return imageURL
        }
        
        return nil
    }

    public var body: some View {
        Button {
            onItemTap(channel)
        } label: {
            HStack(spacing: 10) {
                if !channel.isDirectMessageChannel, let imageUrl = channelActivityImageUrl {
                    CustomActivityImageView(url: imageUrl, size: CGSize(width: 40, height: 40))
                    .allowsHitTesting(false)
                } else {
                    CustomChannelAvatarView(
                        avatar: avatar,
                        showOnlineIndicator: false,
                        size: CGSize(width: 40, height: 40)
                    )
                    .allowsHitTesting(false)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("ChannelAvatarView")
                }

                VStack(alignment: .center, spacing: 2) {
                    HStack(spacing: 4) {
                        CustomChatTitleView(name: channelName, isRead: isRead)

                        Spacer()
                        
                        if let image = image {
                            Image(uiImage: image)
                                .customizable()
                                .frame(maxHeight: 12)
                                .foregroundColor(Color(colors.subtitleText))
                        }

                        if !isRead {
                            CustomUnreadIndicatorView(
                                unreadCount: channel.unreadCount.messages
                            )
                        }
                    }
                    
                    if channel.subtitleText != nil {
                        HStack {
                            subtitleView

                            Spacer()

                            HStack(spacing: 4) {
                                if shouldShowReadEvents {
                                    CustomMessageReadIndicatorView(
                                        isRead: isRead,
                                        isReadByAll: isReadByAll
                                    )
                                }
                                
                                if let lastMessageAt = channel.lastMessageAt {
                                    CustomSubtitleText(text: formatRelative(date: lastMessageAt, locale: localeSettings.locale))
                                        .accessibilityIdentifier("timestampView")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
//        .simultaneousGesture(LongPressGesture().onEnded { _ in
//            onLongPress(channel)
//        })
//        .simultaneousGesture(TapGesture().onEnded {
//            onItemTap(channel)
//        })
        .foregroundColor(.black)
        .disabled(disabled)
        .id("\(channel.id)-base")
    }

    private var subtitleView: some View {
        HStack(spacing: 8) {
            if let subtitle = channel.subtitleText {
                CustomSubtitleText(text: subtitle)
            }
            
            Spacer()
        }
        .accessibilityIdentifier("subtitleView")
    }

    private var shouldShowReadEvents: Bool {
        if let message = channel.latestMessages.first,
           message.isSentByCurrentUser,
           !message.isDeleted {
            return channel.config.readEventsEnabled
        }

        return false
    }

    private var image: UIImage? {
        if channel.isMuted {
            return images.muted
        }
        return nil
    }
}

/// View displaying the user's unread messages in the channel list item.
public struct CustomUnreadIndicatorView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var unreadCount: Int

    public init(unreadCount: Int) {
        self.unreadCount = unreadCount
    }

    public var body: some View {
        Text("\(unreadCount)")
            .lineLimit(1)
            .font(fonts.caption2.leading(.tight))
            .foregroundColor(Color(colors.staticColorText))
            .frame(width: unreadCount < 10 ? 18 : nil, height: 18)
            .padding(.horizontal, unreadCount < 10 ? 0 : 6)
            .background(Color("Orange"))
            .cornerRadius(9)
            .accessibilityIdentifier("UnreadIndicatorView")
    }
}

/// View for the avatar used in channels (includes online indicator overlay).
public struct CustomChannelAvatarView: View {

    var avatar: UIImage
    var showOnlineIndicator: Bool
    var size: CGSize = .defaultAvatarSize

    public init(
        avatar: UIImage,
        showOnlineIndicator: Bool,
        size: CGSize = .defaultAvatarSize
    ) {
        self.avatar = avatar
        self.showOnlineIndicator = showOnlineIndicator
        self.size = size
    }

    public var body: some View {
        LazyView(
            CustomAvatarView(avatar: avatar, size: size)
                .overlay(
                    showOnlineIndicator ?
                        TopRightView {
                            CustomOnlineIndicatorView(indicatorSize: size.width * 0.3)
                        }
                        .offset(x: 3, y: -1)
                        : nil
                )
        )
        .accessibilityIdentifier("ChannelAvatarView")
    }
}

/// View used for the online indicator.
public struct CustomOnlineIndicatorView: View {
    @Injected(\.colors) private var colors

    var indicatorSize: CGFloat

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.textInverted))
                .frame(width: indicatorSize, height: indicatorSize)

            Circle()
                .fill(Color(colors.alternativeActiveTint))
                .frame(width: innerCircleSize, height: innerCircleSize)
        }
    }

    private var innerCircleSize: CGFloat {
        2 * indicatorSize / 3
    }
}
