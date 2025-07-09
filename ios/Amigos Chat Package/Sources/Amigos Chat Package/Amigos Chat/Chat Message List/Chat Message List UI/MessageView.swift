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

    @ObservedObject private var viewModel: MessageViewModel

    let onQuotedMessageTap: ((String) -> Void)?

    private let defaultTextPadding = EdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
    )

    let maxWidth: CGFloat

    init(
        viewModel: MessageViewModel,
        maxWidth: CGFloat = .messageWidth,
        onQuotedMessageTap: ((String) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onQuotedMessageTap = onQuotedMessageTap
        self.maxWidth = maxWidth
        viewModel.resolveMessageType()
    }

    var body: some View {
        if viewModel.isDeleted {

            LocalDeletedMessageView(
                isRightAligned: viewModel.isSentByCurrentUser,
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
                    sharedLocationView
                    mediaAttachmentView
                    walkthroughView
                }
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

    private var walkthroughView: some View {
        Group {
            if let type = viewModel.layoutMessageType, case let .messageWalkthrough(messageWalkthroughType) = type {
                AmiMessageWalkthrough(type: messageWalkthroughType)
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
                /// when `attachmentsPadding` is zero. We need to add an other padding because we don't want the same padding when there are any attachments or quoted messages
                .padding(attachmentsPadding == EdgeInsets(.zero) ? defaultTextPadding : EdgeInsets(.zero))
                .frame(width: viewModel.hasAttachment ? maxWidth : nil, alignment: .leading)
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
                .frame(maxWidth: viewModel.hasAttachment ? maxWidth : .infinity, alignment: .leading)
                .background(.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                /// custom padding calculation
                .padding(
                    attachmentsPadding == EdgeInsets(.zero) ? EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 2,
                        trailing: 0
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
            }
        }
    }

    private var mediaAttachmentView: some View {
        Group {
            switch viewModel.attachmentType {

            case .image, .video:
                singleMediaAttachmentView

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

    private var singleMediaAttachmentView: some View {
        Group {
            if let viewData = viewModel.singleMediaAttachment {
                SingleMediaAttachmentView(
                    viewModel: viewData,
                    maxWidth: maxWidth
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
            viewModel.layoutMessageType != nil {
            return EdgeInsets(.zero)
        }

        return defaultTextPadding
    }

    var sharedLocationView: some View {

        Group {
            if let location = viewModel.locationAttachment {
                ShareLocationMessageView(
                    viewModel: CustomShareLocationMessageViewModel(
                        location: location,
                        user: viewModel.author
                    ),
                    width: maxWidth
                )

                .clipShape(
                    RoundedRectangle(
                        cornerRadius: attachmentsPadding != EdgeInsets(
                            .zero
                        ) || viewModel.quotedMessage != nil ? 18 : 0
                    )
                )

                .overlay(
                    RoundedRectangle(
                        cornerRadius: attachmentsPadding != EdgeInsets(
                            .zero
                        )  ? 18 : 0
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
