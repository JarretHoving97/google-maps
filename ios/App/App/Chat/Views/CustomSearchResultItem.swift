import StreamChatSwiftUI
import StreamChat
import SwiftUI

/// The search result item user interface.
struct CustomSearchResultItem<ChannelDestination: View>: View {

    @Injected(\.utils) private var utils

    var searchResult: ChannelSelectionInfo
    var onlineIndicatorShown: Bool
    var channelName: String
    var avatar: UIImage
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var channelDestination: (ChannelSelectionInfo) -> ChannelDestination

    var channel: ChatChannel {
        searchResult.channel
    }

    private var channelActivityImageUrl: URL? {
        if let imageURL = channel.imageURL {
            return imageURL
        }

        return nil
    }

    var body: some View {
        Button {
            onSearchResultTap(searchResult)
        } label: {
            HStack {
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

                VStack(alignment: .leading, spacing: 4) {
                    CustomChatTitleView(name: channelName, isRead: !searchResult.channel.isUnread)

                    HStack {
                        CustomSubtitleText(text: searchResult.message?.text ?? "")
                        Spacer()
                        CustomSubtitleText(text: timestampText)
                    }
                }
            }
            .padding(.all, 8)
        }
        .accessibilityIdentifier("SearchResultItem")
    }

    private var timestampText: String {
        if let lastMessageAt = searchResult.channel.lastMessageAt {
            return utils.dateFormatter.string(from: lastMessageAt)
        } else {
            return ""
        }
    }
}
