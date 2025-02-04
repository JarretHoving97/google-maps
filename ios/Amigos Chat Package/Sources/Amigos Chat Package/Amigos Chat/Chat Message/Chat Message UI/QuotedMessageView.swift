//
//  QuotedMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

class QuotedMessageViewModel {

    public var messageText: String {
        message.text
    }
    public var isSentByCurrentUser: Bool {
        return message.isSentByCurrentUser
    }

    public var isDeleted: Bool {
        return message.isDeleted
    }

    public var author: String {
        message.user.name
    }

    let imageLoader: ImageLoader

    let imageCDN: ImageCDNhandler

    let videoPreviewLoader: PreviewVideoLoader

    private let message: Message

    init(
        message: Message,
        imageLoader: ImageLoader = DefaultImageLoader(),
        imageCDN: ImageCDNhandler = MockImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader()
    ) {
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
        self.videoPreviewLoader = videoPreviewLoader
        self.message = message
    }

    var mediaAttachments: [MediaAttachment] {
        message.attachments.compactMap { $0.mediaAttachment(with: imageLoader, cdn: imageCDN, videoPreviewLoader: videoPreviewLoader) }
    }

}

struct QuotedMessageView: View {

    let viewModel: QuotedMessageViewModel

    init(viewModel: QuotedMessageViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(spacing: 4) {
            Rectangle()
                .frame(width: 5)
                .foregroundStyle(Color.orange)

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.author)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Color.orange)

                content
            }
            .padding(8)
            .frame(alignment: .leading)
        }
        .frame(alignment: .leading)
        .background(.black.opacity(0.1))
    }

    private var content: some View {
        Group {

            if viewModel.isDeleted {
                LocalDeletedMessageView(
                    isRightAligned: true,
                    isSentByCurrentUser: viewModel.isSentByCurrentUser
                )

            } else {
                VStack(alignment: .leading, spacing: 10) {

                    if let attachment = viewModel.mediaAttachments.first {
                        LazyLoadImage(source: attachment, width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    if !viewModel.messageText.isEmpty {
                        Text(viewModel.messageText)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .lineLimit(3)
                    }
                }
            }
        }
    }
}

#Preview {

    QuotedMessageView(
        viewModel: QuotedMessageViewModel(
            message: Message(
                message: "What's up dude?",
                attachments: [
                    .image(ImageAttachment(imageUrl: ImageURLExamples.portraitImageUrl, uploadingState: .none))
                ]
            )
        )
    )
}
