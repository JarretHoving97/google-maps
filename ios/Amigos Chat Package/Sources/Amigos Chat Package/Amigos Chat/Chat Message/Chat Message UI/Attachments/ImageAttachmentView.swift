//
//  ImageAttachmentView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

public struct ImageAttachmentView: View {

    let loader: ImageLoader
    let imageCDN: ImageCDNhandler
    let attachment: ImageAttachment
    let width: CGFloat

    init(attachment: ImageAttachment, loader: ImageLoader, imageCDN: ImageCDNhandler, width: CGFloat = .messageWidth) {
        self.attachment = attachment
        self.imageCDN = imageCDN
        self.loader = loader
        self.width = width
    }

    public var body: some View {
        LazyLoadImage(
            source: MediaAttachment(
                imageLoader: loader,
                imageCDN: imageCDN,
                videoPreviewLoader: DefaultPreviewVideoLoader(),
                url: attachment.imageUrl,
                type: .image,
                uploadingState: nil
            ),
            width: width,
            height: height(width: width)
        )
        .withUploadingStateIndicator(for: attachment.uploadingState, url: attachment.imageUrl)
    }

    ///  The computed height as 3/4 of the width.
    private func height(width: CGFloat) -> CGFloat {
        3 * width / 4
    }
}

#Preview {
    MessageView(
        viewModel: MessageViewModel(
            message: Message(
                isSentByCurrentUser: true,
                attachments: [
                    .image(
                        ImageAttachment(
                            imageUrl: ImageURLExamples.portraitImageUrl,
                            uploadingState: .some(UploadingState(localFileURL: ImageURLExamples.portraitImageUrl, state: .uploading(progress: 0.8)))
                        )
                    )
                ]
            )
        )
    )
}
