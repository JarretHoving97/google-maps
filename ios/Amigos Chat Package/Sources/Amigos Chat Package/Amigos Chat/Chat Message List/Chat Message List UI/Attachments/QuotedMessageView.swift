//
//  QuotedMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

struct QuotedMessageView: View {

    let viewModel: QuotedMessageViewModel

    init(viewModel: QuotedMessageViewModel) {
        self.viewModel = viewModel
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
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {

            if viewModel.hasUnsupportedAttachment {
                UnsupportedAttachmentView()

            } else if let poll = viewModel.pollAttachment {
                Text("📊 \(poll.name)")
                    .font(.caption1)
                    .foregroundColor(Color(.grey))
            } else {

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
