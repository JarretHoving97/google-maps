import SwiftUI
import StreamChat
import StreamChatSwiftUI

/// View for the quoted message.
public struct CustomQuotedMessageView<Factory: ViewFactory>: View {

    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private let attachmentWidth: CGFloat = 36

    public var factory: Factory
    public var quotedMessage: ChatMessage
    public var fillAvailableSpace: Bool
    public var isInComposer: Bool

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        isInComposer: Bool
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        self.isInComposer = isInComposer
    }

    public var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                if let authorName = quotedMessage.author.name {
                    Text(authorName)
                        .foregroundColor(colorByHashingString)
                        .lineLimit(1)
                        .font(fonts.footnoteBold)
                        .padding(.bottom, 2)
                }

                if !quotedMessage.attachmentCounts.isEmpty {
                    ZStack {
                        if messageTypeResolver.hasCustomAttachment(message: quotedMessage) {
                            factory.makeCustomAttachmentQuotedView(for: quotedMessage)
                        } else if hasVoiceAttachments {
                            CustomVoiceRecordingPreview(
                                voiceAttachment: quotedMessage.voiceRecordingAttachments[0].payload,
                                foregroundStyleDark: isInComposer
                            )
                        } else if !quotedMessage.imageAttachments.isEmpty {
                            AsyncImage(url: quotedMessage.imageAttachments[0].imageURL) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: attachmentWidth, height: attachmentWidth)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else if !quotedMessage.giphyAttachments.isEmpty {
                            // We don't support giphy attachment as of now.
                        } else if !quotedMessage.fileAttachments.isEmpty {
                            Image(uiImage: filePreviewImage(for: quotedMessage.fileAttachments[0].assetURL))
                        } else if !quotedMessage.videoAttachments.isEmpty {
                            VideoAttachmentView(
                                attachment: quotedMessage.videoAttachments[0],
                                message: quotedMessage,
                                width: attachmentWidth,
                                ratio: 1.0,
                                cornerRadius: 0
                            )
                        } else if !quotedMessage.linkAttachments.isEmpty {
                            AsyncImage(url: quotedMessage.linkAttachments[0].previewURL ?? quotedMessage.linkAttachments[0].originalURL) { image in
                                 image.resizable()
                             } placeholder: {
                                 ProgressView()
                             }
                             .frame(width: attachmentWidth, height: attachmentWidth)
                             .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(width: hasVoiceAttachments ? nil : attachmentWidth, height: attachmentWidth)
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(8)
                    .padding(.vertical, 2)
                    .allowsHitTesting(false)
                }

                Text(textForMessage)
                    .foregroundColor(Color("Grey"))
                    .lineLimit(3)
                    .font(fonts.caption1)
                    .accessibility(identifier: "quotedMessageText")
            }
            .padding(hasVoiceAttachments ? [.top, .bottom] : .all, 8)
            .padding(.leading, 12)
            .padding(.trailing, 8)

            if fillAvailableSpace {
                Spacer()
            }
        }
        .id(quotedMessage.id)
        .overlay(
            HStack {
                Rectangle()
                    .frame(maxWidth: 4, maxHeight: .infinity)
                    .foregroundColor(colorByHashingString)

                Spacer()
            }
        )
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: quotedMessage,
                    isFirst: true,
                    injectedBackgroundColor: bubbleBackground,
                    cornerRadius: 14,
                    forceLeftToRight: isInComposer
                )
            )
        )
        .accessibilityElement(children: .contain)
    }

    private var colorByHashingString: Color {
        if let name = quotedMessage.author.name {
            return getColorByHashingString(name)
        }

        return Color(colors.alternativeActiveTint)
    }

    private var bubbleBackground: UIColor {
        if !quotedMessage.linkAttachments.isEmpty {
            return colors.highlightedAccentBackground1
        }

        var colors = colors
        let color = quotedMessage.isSentByCurrentUser ?
            colors.quotedMessageBackgroundCurrentUser : colors.quotedMessageBackgroundOtherUser
        return color
    }

    private func filePreviewImage(for url: URL) -> UIImage {
        let iconName = url.pathExtension
        return images.documentPreviews[iconName] ?? images.fileFallback
    }

    private var textForMessage: String {
        if !quotedMessage.text.isEmpty {
            return quotedMessage.adjustedText
        }

//        if !quotedMessage.imageAttachments.isEmpty {
//            return L10n.Composer.Quoted.photo
//        } else if !quotedMessage.giphyAttachments.isEmpty {
//            return L10n.Composer.Quoted.giphy
//        } else if !quotedMessage.fileAttachments.isEmpty {
//            return quotedMessage.fileAttachments[0].title ?? ""
//        } else if !quotedMessage.videoAttachments.isEmpty {
//            return L10n.Composer.Quoted.video
//        }

        return ""
    }

    private var hasVoiceAttachments: Bool {
        !quotedMessage.voiceRecordingAttachments.isEmpty
    }
}

struct CustomVoiceRecordingPreview: View {

    @Injected(\.images) var images
    @Injected(\.utils) var utils

    let voiceAttachment: VoiceRecordingAttachmentPayload
    let foregroundStyleDark: Bool

    init(voiceAttachment: VoiceRecordingAttachmentPayload, foregroundStyleDark: Bool) {
        self.voiceAttachment = voiceAttachment
        self.foregroundStyleDark = foregroundStyleDark
    }

    var body: some View {
        HStack {
            CustomWaveformViewSwiftUI(
                addedVoiceRecording: AddedVoiceRecording(
                    url: voiceAttachment.voiceRecordingURL,
                    duration: voiceAttachment.duration ?? 0,
                    waveform: voiceAttachment.waveformData ?? []
                ),
                foregroundStyleDark: foregroundStyleDark,
                isPreview: true
            )
            .frame(height: 30)
        }
    }
}
