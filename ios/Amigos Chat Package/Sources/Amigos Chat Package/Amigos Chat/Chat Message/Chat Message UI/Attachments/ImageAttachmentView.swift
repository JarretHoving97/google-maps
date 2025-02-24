//
//  ImageAttachmentView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

public struct ImageAttachmentView: View {

    @State private var aspectRatio: CGFloat? /// Store aspect ratio once the image is loaded

    let author: LocalUser
    let loader: ImageLoader
    let imageCDN: ImageCDNhandler
    let attachment: ImageAttachment
    let width: CGFloat

    init(
        author: LocalUser,
        attachment: ImageAttachment,
        loader: ImageLoader,
        imageCDN: ImageCDNhandler,
        width: CGFloat = .messageWidth
    ) {
        self.attachment = attachment
        self.imageCDN = imageCDN
        self.loader = loader
        self.width = width
        self.author = author
    }

    public var body: some View {
        ZStack {
            LazyLoadImage(
                source: MediaAttachment(
                    imageLoader: loader,
                    imageCDN: imageCDN,
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: attachment.imageUrl,
                    type: .photo,
                    uploadingState: nil
                ),
                width: width,
                height: finalHeight(), /// Also default height while loading
                onImageLoaded: { image in
                    aspectRatio = image.size.width / image.size.height /// Extract aspect ratio
                }
            )
        }
        .withUploadingStateIndicator(for: attachment.uploadingState, url: attachment.imageUrl)
        .contentShape(Rectangle()) /// Needed to recognize tap gesture
    }

       /// Calculates the final height based on the aspect ratio and constraints.
       private func finalHeight() -> CGFloat {
           guard let aspectRatio = aspectRatio else { return 400 }

           let calculatedHeight = width / aspectRatio
           return min(calculatedHeight, 400)
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
