//
//  MessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

extension CGFloat {

    public static var messageWidth: CGFloat {
        UIScreen.main.bounds.width * 0.6
    }
}

struct MessageView: View {

    let viewModel: MessageViewModel

    @State private var selectedSingleAttachment: MediaAttachment?

    let onQuotedMessageTap: ((String) -> Void)?

    private let defaultTextPadding = EdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
    )

    let maxWidth: CGFloat = .messageWidth

    init(viewModel: MessageViewModel, onQuotedMessageTap: ((String) -> Void)? = nil) {
        self.viewModel = viewModel
        viewModel.resolveMessageType()
        self.onQuotedMessageTap = onQuotedMessageTap
    }

    var body: some View {
        if viewModel.isDeleted {

            LocalDeletedMessageView(
                isRightAligned: viewModel.isFirst,
                isSentByCurrentUser: viewModel.isSentByCurrentUser
            )
            .modifier(bubbleResolvedModifier)

        } else if viewModel.asSuperEmoji {

            VStack(spacing: 0) {
                quotedMessageView
                Text(viewModel.messageText)
                    .font(Font.system(size: 50))
                    .frame(height: 50)
            }
            .modifier(bubbleResolvedModifier)

        } else {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 6) {
                    quotedMessageView
                    sharedLoactionView
                    mediaAttachmentView
                    walkthroughView
                }
                messageTextView
            }

            .modifier(bubbleResolvedModifier)
            .fullScreenCover(isPresented: $selectedSingleAttachment.toBoolBinding) {

                SingleAttachmentGalleryView(
                    isPresented: $selectedSingleAttachment.toBoolBinding,
                    viewModel: SingleAttachmentViewModel(
                        author: viewModel.author,
                        attachment: selectedSingleAttachment!
                    )
                )
            }
        }
    }

    private var bubbleInfo: MessageBubbleViewModifier.MessageBubbleModel {
        .init(
            isSentByCurrentUser: viewModel.isSentByCurrentUser,
            isFirst: viewModel.isFirst,
            forceLeftToRight: viewModel.forceLeftToRight
        )
    }
}

// MARK: View Components

extension MessageView {

    private var walkthroughView: some View {

        Group {
            if let type = viewModel.walkthroughType {
                AmiMessageWalkthrough(type: type)
            }
        }
    }

    private var messageTextView: some View {
        Group {
            if !viewModel.messageText.isEmpty {
                LinkDetectionTextView(
                    viewModel: LinkDetectionTextViewModel(
                        isSentByCurrentUser: viewModel.isSentByCurrentUser,
                        isModerator: viewModel.author.isModerator,
                        text: viewModel.messageText
                    )
                )
                .multilineTextAlignment(.leading)
                .frame(alignment: .leading)
                /// when `attachmentsPadding` is zero. We need to add an other padding because we don't want the same padding when there are any attachments or quoted messages
                .padding(attachmentsPadding == EdgeInsets(.zero) ? defaultTextPadding : EdgeInsets(.zero))
            } else {
                EmptyView()
            }
        }
    }

    private var quotedMessageView: some View {
        Group {
            if let message = viewModel.quotedMessage {
                QuotedMessageView(
                    viewModel: QuotedMessageViewModel(
                        message: message,
                        isSentByCurrentUser: viewModel.isSentByCurrentUser,
                        imageLoader: viewModel.imageLoader,
                        imageCDN: viewModel.imageCDN,
                        videoPreviewLoader: viewModel.videoPreviewLoader
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                /// custom padding calculation
                .padding(
                    attachmentsPadding == EdgeInsets(.zero) ? EdgeInsets(
                        top: 4,
                        leading: 4,
                        bottom: 4,
                        trailing: 2
                    ) :  EdgeInsets(
                        top: -2,
                        leading: -10,
                        bottom: 10,
                        trailing: -10
                    )
                )
                .fixedSize(horizontal: false, vertical: true)
                .onTapGesture {
                    onQuotedMessageTap?(message.id)
                }
            } else {
                EmptyView()
            }
        }
    }

    private var mediaAttachmentView: some View {
        Group {
            switch viewModel.attachmentType {

            case .image:
                singleImageView

            case .video:
                singleVideoPreviewView

            case .multimedia:

                MultiMediaView(
                    user: viewModel.author,
                    sources: viewModel.mediaAttachments,
                    isSentByCurrentUser: viewModel.isSentByCurrentUser,
                    width: maxWidth
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: attachmentsPadding != EdgeInsets(.zero) ? 18 : 0
                    )
                )

            default:
                EmptyView()
            }
        }
    }

    /// safely unwrap image attachments, otherwise don't show any view
    private var singleImageView: some View {
        Group {
            if let image = viewModel.imageAttachments.first {
                ImageAttachmentView(
                    author: viewModel.author,
                    attachment: image,
                    loader: viewModel.imageLoader,
                    imageCDN: viewModel.imageCDN,
                    width: maxWidth
                )
                .overlay(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSingleAttachment = viewModel.mediaAttachments.first
                        }
                )
            }
        }
    }

    private var singleVideoPreviewView: some View {
        Group {
            if let video = viewModel.videoAttachments.first {
                VideoPreviewAttachmentView(
                    user: viewModel.author,
                    videoPreviewLoader: viewModel.videoPreviewLoader,
                    attachment: video,
                    width: maxWidth
                )
                .overlay(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSingleAttachment = viewModel.mediaAttachments.first
                        }
                )
            }
        }
    }

    private var bubbleResolvedModifier: ResolvedViewModifier {
        return ResolvedViewModifier(
            MessageBubbleViewModifier(
                contentInsets: attachmentsPadding,
                hidden: viewModel.bubbleHidden,
                model: bubbleInfo
            )
        )
    }

    var attachmentsPadding: EdgeInsets {
        if viewModel.isDeleted ||
            !viewModel.mediaAttachments.isEmpty ||
            (viewModel.asSuperEmoji && viewModel.quotedMessage == nil) ||
            viewModel.locationAttachment != nil ||
            viewModel.walkthroughType != nil {
            return EdgeInsets(.zero)
        }

        return defaultTextPadding
    }

    var sharedLoactionView: some View {
        Group {
            if let location = viewModel.locationAttachment {
                ShareLocationMessageView(
                    viewModel: CustomShareLocationMessageViewModel(
                        location: location,
                        user: viewModel.author
                    )
                )

                .clipShape(
                    RoundedRectangle(
                        cornerRadius: attachmentsPadding != EdgeInsets(
                            .zero
                        ) ? 18 : 0
                    )
                )

                .overlay(
                    RoundedRectangle(
                        cornerRadius: attachmentsPadding != EdgeInsets(
                            .zero
                        ) ? 18 : 0
                    )
                    .stroke(
                        .white,
                        lineWidth: viewModel.isSentByCurrentUser ? 0.5 : 0
                    )
                )
            }
        }
    }
}

#Preview {
    MessageView(
        viewModel: MessageViewModel(
            message: Message(
                isSentByCurrentUser: true,
                message: TextExamples.messageWithLinks,
                quotedMessage: { Message(
                    message: TextExamples.largeMessageText,
                    attachments: [
                        .image(
                            ImageAttachment(
                                imageUrl: ImageURLExamples.portraitImageUrl,
                                uploadingState: .none
                            )
                        )
                    ]
                )
                },
                isDeleted: false,
                attachments: [
                    .image(
                        ImageAttachment(
                            imageUrl: ImageURLExamples.portraitImageUrl,
                            uploadingState: .none
                        )
                    ),
                    .image(
                        ImageAttachment(
                            imageUrl: ImageURLExamples.landscapeImageUrl,
                            uploadingState: .some(UploadingState(localFileURL: ImageURLExamples.portraitImageUrl, state: .uploading(progress: 0.9)))
                        )
                    ),
                    .video(
                        VideoAttachment(
                            url: VideoURLExamples.example1,
                            uploadingState: .none
                        )
                    )
                ]
            )
        )
    )
    .frame(width: UIScreen.main.bounds.size.width * 0.6)
}
