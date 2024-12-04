import StreamChat
import SwiftUI
import StreamChatSwiftUI

/// View displayed when a message is deleted.
struct DeletedMessageView: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.images) private var images
    @Injected(\.fonts) var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }

    private var deletedMessageVisibility: ChatClientConfig.DeletedMessageVisibility {
        chatClient.config.deletedMessagesVisibility
    }

    var message: ChatMessage
    var isFirst: Bool

    public var body: some View {
        VStack(
            alignment: message.isRightAligned ? .trailing : .leading,
            spacing: 4
        ) {
            HStack(spacing: 6) {
                Text("message.deleted-message-placeholder")
                    .font(fonts.caption1.italic())

                Image(systemName: "trash.fill")
                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 12, height: 12, alignment: .center)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("Grey Light"))
            .foregroundColor(Color(colors.textLowEmphasis))
            .cornerRadius(12)
            .accessibilityIdentifier("DeletedMessageText")

            if message.isSentByCurrentUser {
                HStack {
                    if message.isRightAligned {
                        Spacer()
                    }

                    if deletedMessageVisibility == .visibleForCurrentUser {
                        Image(uiImage: images.eye)
                            .customizable()
                            .frame(maxWidth: 12)
                            .accessibilityIdentifier("onlyVisibleToYouImageView")

                        Text("message.only-visible-to-you")
                            .font(fonts.footnote)
                            .accessibilityIdentifier("onlyVisibleToYouLabel")
                    }

                    Text(dateFormatter.string(from: message.createdAt))
                        .font(Font.custom(size: 10, weight: ThemeFontWeight.medium))
                }
                .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("DeletedMessageView")
    }
}
