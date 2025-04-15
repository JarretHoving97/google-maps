//
//  QuotedMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

struct QuotedMessageView: View {

    let viewModel: QuotedMessageViewModel
    let maxWidth: CGFloat

    init(viewModel: QuotedMessageViewModel, maxWidth: CGFloat = .messageWidth) {
        self.viewModel = viewModel
        self.maxWidth = maxWidth
    }

    var body: some View {
        let color = colorByString(viewModel.author)

        HStack(spacing: 4) {
            Rectangle()
                .frame(width: 5)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.author)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(color)

                content
            }
            .padding(8)
        }
        .frame(maxWidth: maxWidth, alignment: .leading)
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
                            .frame(width: 40, height: 40)
                    }

                    if let location = viewModel.locationAttachment {
                        QuotedLocationView(
                            viewModel: QuotedLocationViewModel(
                                locationAttachment: location,
                                isSentByCurrentUser: viewModel.isSentByCurrentUser
                            )
                        )
                    }
                    if !viewModel.messageText.isEmpty {
                        Text(viewModel.messageText)
                            .frame(alignment: .leading)
                            .multilineTextAlignment(.leading)
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
            ), isSentByCurrentUser: true
        )
    )
}
