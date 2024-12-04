import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomMessageView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    public var factory: Factory
    public var channel: ChatChannel
    public var message: ChatMessage
    public var contentWidth: CGFloat
    public var isFirst: Bool
    @Binding public var scrolledId: String?

    public init(factory: Factory, channel: ChatChannel, message: ChatMessage, contentWidth: CGFloat, isFirst: Bool, scrolledId: Binding<String?>) {
        self.factory = factory
        self.channel = channel
        self.message = message
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack {
            if messageTypeResolver.isDeleted(message: message) {
                factory.makeDeletedMessageView(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth
                )
            } else if messageTypeResolver.hasCustomAttachment(message: message) {
//                Custom attachments are disabled.
//                factory.makeCustomAttachmentViewType(
//                    for: message,
//                    isFirst: isFirst,
//                    availableWidth: contentWidth,
//                    scrolledId: $scrolledId
//                )
            } else if !message.attachmentCounts.isEmpty {
                if messageTypeResolver.hasLinkAttachment(message: message) {
                    factory.makeLinkAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }

//                Files are disabled.
//                if messageTypeResolver.hasFileAttachment(message: message) {
//                    factory.makeFileAttachmentView(
//                        for: message,
//                        isFirst: isFirst,
//                        availableWidth: contentWidth,
//                        scrolledId: $scrolledId
//                    )
//                }

                if messageTypeResolver.hasImageAttachment(message: message) {
                    factory.makeImageAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }

//                Giphys are disabled.
//                if messageTypeResolver.hasGiphyAttachment(message: message) {
//                    factory.makeGiphyAttachmentView(
//                        for: message,
//                        isFirst: isFirst,
//                        availableWidth: contentWidth,
//                        scrolledId: $scrolledId
//                    )
//                }

                if messageTypeResolver.hasVideoAttachment(message: message) {
                    factory.makeVideoAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }

//                Voice recordings are disabled.
//                if messageTypeResolver.hasVoiceRecording(message: message) {
//                    factory.makeVoiceRecordingView(
//                        for: message,
//                        isFirst: isFirst,
//                        availableWidth: contentWidth,
//                        scrolledId: $scrolledId
//                    )
//                }
            } else {
                if message.shouldRenderAsJumbomoji {
                    factory.makeEmojiTextView(
                        message: message,
                        scrolledId: $scrolledId,
                        isFirst: isFirst
                    )
                } else if !message.text.isEmpty {
                    CustomMessageTextView(
                        factory: factory,
                        channel: channel,
                        message: message,
                        isFirst: isFirst,
                        leadingPadding: 16,
                        trailingPadding: 16,
                        topPadding: 8,
                        bottomPadding: 12,
                        scrolledId: $scrolledId
                    )
                }
            }
        }
    }
}

public struct CustomMessageTextView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils

    private let factory: Factory
    private var channel: ChatChannel
    private let message: ChatMessage
    private let isFirst: Bool
    private let leadingPadding: CGFloat
    private let trailingPadding: CGFloat
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        channel: ChatChannel,
        message: ChatMessage,
        isFirst: Bool,
        leadingPadding: CGFloat = 16,
        trailingPadding: CGFloat = 16,
        topPadding: CGFloat = 8,
        bottomPadding: CGFloat = 8,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.channel = channel
        self.message = message
        self.isFirst = isFirst
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        _scrolledId = scrolledId
    }

    private var showAuthor: Bool {
        !message.isRightAligned && !channel.isDirectMessageChannel
    }

    private var messageWalkthroughType: MessageWalkthroughType? {
        if let key = message.layoutKey {
            if let value = MessageWalkthroughType(rawValue: key) {
                return value
            }
        }

        return nil
    }

    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if showAuthor {
                CustomMessageAuthorView(message: message)
                    .padding(.leading, leadingPadding)
                    .padding(.trailing, trailingPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 2)
            }

            if let quotedMessage = message.quotedMessage {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
                .padding(.bottom, 8)
            }

            if let type = messageWalkthroughType {
                AmiMessageWalkthrough(type: type)
            }

            CustomStreamTextView(message: message)
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
                .padding(.top, showAuthor ? 0 : 12)
                .padding(.bottom, bottomPadding)
                .fixedSize(horizontal: false, vertical: true)
                .id("\(message.id)-\(message.textUpdatedAt?.ISO8601Format() ?? "unedited")")
        }
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst,
                    cornerRadius: 14
                )
            )
        )
        .accessibilityIdentifier("MessageTextView")
    }
}

public struct CustomStreamTextView: View {

    @Injected(\.fonts) var fonts

    var message: ChatMessage

    public var body: some View {
        if #available(iOS 15, *) {
            LinkDetectionTextView(message: message)
        } else {
            Text(message.adjustedText)
                .foregroundColor(textColor(for: message))
                .font(fonts.caption1)
                .lineSpacing(2)
        }
    }
}

@available(iOS 15, *)
public struct LinkDetectionTextView: View {

    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils

    var message: ChatMessage

    var text: LocalizedStringKey {
        LocalizedStringKey(message.adjustedText)
    }

    @State var displayedText: AttributedString?

    @State var linkDetector = TextLinkDetector()

    @State var tintColor = InjectedValues[\.colors].tintColor

    @State private var showUrlConfirmation = false

    @State private var confirmUrl: URL?

    public init(message: ChatMessage) {
        self.message = message
    }

    private var markdownEnabled: Bool {
        utils.messageListConfig.markdownSupportEnabled
    }

    private var isModerator: Bool {
        message.author.userRole == .moderator
    }

    private func handleLinkTap(_ url: URL) {
        let webViewURL = getWebViewURL()

        if url.host == webViewURL.host {
            ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: url.relativePath, dismiss: true)
        } else {
            confirmUrl = url
            showUrlConfirmation = true
        }
    }

    public var body: some View {
        Group {
            if let displayedText {
                Text(displayedText)
            } else if isModerator {
                Text(text)
            } else {
                Text(message.adjustedText)
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            switch url.scheme {
                case "http", "https":
                    handleLinkTap(url)
                    return .handled
                default:
                    return .systemAction
            }
        })
        .confirmationDialog(
            "custom.message.url.confirm.title",
            isPresented: $showUrlConfirmation,
            titleVisibility: .visible
        ) {
            Button("custom.leaveAmigos") {
                if let url = confirmUrl, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            Button("custom.cancel", role: .cancel) {}
        } message: {
            Text(confirmUrl?.absoluteString ?? "")
        }
        .foregroundColor(textColor(for: message))
        .font(fonts.caption1)
        .tint(message.isRightAligned ? Color.white : Color("Purple"))
        .onAppear {
            detectLinks(for: message)
        }
        .onChange(of: message, perform: { updated in
            detectLinks(for: updated)
        })
    }

    func detectLinks(for message: ChatMessage) {
        // Check if local link detection is enabled in the configuration
        guard utils.messageListConfig.localLinkDetectionEnabled else { return }

        // Avoid setting the `displayedText` for moderators.
        // This allows for both links and markdown links to send.
        guard !isModerator else { return }

        // Initialize attributes dictionary for the text
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor(for: message),
            .font: fonts.caption1
        ]

        // Get additional display options for the message
        let additional = utils.messageListConfig.messageDisplayOptions.messageLinkDisplayResolver(message)
        for (key, value) in additional {
            if key == .foregroundColor, let value = value as? UIColor {
                // Set tint color if a foreground color is provided
                tintColor = Color(value)
            } else {
                // Add other attributes to the attributes dictionary
                attributes[key] = value
            }
        }

        let attributedString = linkify(for: message.adjustedText, attributes: attributes)

        displayedText = attributedString
    }
}
