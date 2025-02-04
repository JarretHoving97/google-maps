//
//  MessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

extension CGFloat {

    static var messageWidth: CGFloat {
        UIScreen.main.bounds.width * 0.76
    }
}

struct MessageView: View {

    let viewModel: MessageViewModel

    private let defaultTextPadding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

    private let width: CGFloat

    init(viewModel: MessageViewModel, width: CGFloat = .messageWidth) {
        self.viewModel = viewModel
        self.width = width
        viewModel.resolveMessageType()
    }

    var body: some View {

        if viewModel.isDeleted {
            LocalDeletedMessageView(
                isRightAligned: viewModel.isFirst,
                isSentByCurrentUser: viewModel.isSentByCurrentUser
            )
        } else {
            VStack(alignment: .leading, spacing: 0) {
                quotedMessageView
                mediaAttachmentView
                messageTextView
            }
            .modifier(bubbleResolvedModifier)
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

    private var messageTextView: some View {
        Group {
            if !viewModel.messageText.isEmpty {
                Text(viewModel.messageText)

                    .foregroundStyle(viewModel.isSentByCurrentUser ? .white : .black)
                    .font(.body)
                /// when `attachmentsPadding` is zero. We need to add an other padding because we don't want the same padding when there are any attachments
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
                    sources: viewModel.mediaAttachments,
                    isSentByCurrentUser: viewModel.isSentByCurrentUser,
                    width: width
                )

            case .empty, .deleted:
                EmptyView()
            }
        }
    }

    /// safely unwrap image attachments, otherwise don't show any view
    private var singleImageView: some View {
        Group {
            if let image = viewModel.imageAttachments.first {
                ImageAttachmentView(
                    attachment: image,
                    loader: viewModel.imageLoader,
                    imageCDN: viewModel.imageCDN,
                    width: width
                )
            } else {
                EmptyView()
            }
        }
    }

    private var singleVideoPreviewView: some View {
        Group {
            if let video = viewModel.videoAttachments.first {
                VideoPreviewAttachmentView(
                    videoPreviewLoader: viewModel.videoPreviewLoader,
                    attachment: video,
                    width: width
                )
            } else {
                EmptyView()
            }
        }

    }

    private var bubbleResolvedModifier: ResolvedViewModifier {
        return ResolvedViewModifier(
            MessageBubbleViewModifier(
                contentInsets: attachmentsPadding,
                model: bubbleInfo
            )
        )
    }

    var attachmentsPadding: EdgeInsets {

        /// if message is deleted. it can still contain attachments etc
        if viewModel.isDeleted {
            return EdgeInsets(.zero)
        }

        if !viewModel.mediaAttachments.isEmpty && !viewModel.messageText.isEmpty {
            return EdgeInsets(.zero)
        }

        if !viewModel.mediaAttachments.isEmpty && viewModel.messageText.isEmpty {
            return EdgeInsets(.zero)
        }

        return defaultTextPadding
    }
}

#Preview {
//    MessageView(
//        viewModel: MessageViewModel(
//            message: Message(
//                isSentByCurrentUser: true,
//                message: TextExamples.largeMessageText,
//                quotedMessage: { Message(
//                    message: TextExamples.largeMessageText,
//                    attachments: [
//                        .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .none))
//                    ]
//                )
//                },
//
//                isDeleted: false,
//                attachments: [
//                    .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .none)),
//                    .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .some(UploadingState(localFileURL: ImageURLExamples.portraitImageUrl, state: .uploading(progress: 0.9))))),
//                    .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .some(UploadingState(localFileURL: ImageURLExamples.portraitImageUrl, state: .uploading(progress: 0.9))))),
//                    .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .none)),
//                    .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .none))
//                ]
//            )
//        )
//    )

    MessageView(
        viewModel: MessageViewModel(
            message: Message(
                message: "Allo",
                quotedMessage: {
                    Message(
                        isSentByCurrentUser: true,
                        message: "tesss",
                        quotedMessage: { Message(
                            message: TextExamples.largeMessageText,
                            attachments: [
                                .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .none))
                            ]
                        )
                        }
                    )
                }
            )
        )
    )
}
