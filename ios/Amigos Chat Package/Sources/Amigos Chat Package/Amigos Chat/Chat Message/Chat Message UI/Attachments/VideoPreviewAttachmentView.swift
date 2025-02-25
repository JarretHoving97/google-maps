//
//  VideoAttachmentView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import SwiftUI

struct VideoPreviewAttachmentView: View {

    let videoPreviewLoader: PreviewVideoLoader

    let attachment: VideoAttachment
    let user: LocalUser

    @State var previewImage: UIImage?
    @State var error: Error?

    @State private var galleryPresented: Bool = false

    var ratio: CGFloat = 0.75
    let width: CGFloat

    init(user: LocalUser, videoPreviewLoader: PreviewVideoLoader, attachment: VideoAttachment, width: CGFloat = UIScreen.main.bounds.size.width * 0.68) {
        self.user = user
        self.videoPreviewLoader = videoPreviewLoader
        self.attachment = attachment
        self.width = width
    }

    var body: some View {
        ZStack {
            if let previewImage = previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .allowsHitTesting(false)

                if width > 64 {
                    VStack {
                        VideoPlayIcon()
                    }
                    .frame(width: width, height: width * ratio)
                    .contentShape(Rectangle())
                    .clipped()
                }
            } else if error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }
        }
        .frame(width: width, height: width * ratio)
        .onTapGesture {
            galleryPresented.toggle()
        }
        .withUploadingStateIndicator(for: attachment.uploadingState, url: attachment.url)
        .onAppear {
            videoPreviewLoader.loadPreviewForVideo(at: attachment.url) { result in
                switch result {
                case let .success(image):
                    self.previewImage = image
                case let .failure(error):
                    self.error = error
                }
            }
        }
        .fullScreenCover(isPresented: $galleryPresented) {
            GalleryView(
                viewModel: GalleryViewModel(
                    isShown: $galleryPresented,
                    attachments: [.video(with: attachment.url)],
                    author: user
                )
            )
        }
    }
}

struct VideoPlayIcon: View {

    var width: CGFloat = 24

    var body: some View {
        Image(systemName: "play.fill")
            .customizable()
            .frame(width: width)
            .foregroundColor(.white)
            .modifier(ShadowModifier())
    }
}

#Preview {
    VideoPreviewAttachmentView(
        user: LocalUser(
            id: UUID(),
            name: "Ilon"
        ),
        videoPreviewLoader: DefaultPreviewVideoLoader(),
        attachment: VideoAttachment(
            url: VideoURLExamples.example1,
            uploadingState: UploadingState(localFileURL: VideoURLExamples.example1, state: .uploading(progress: 0.2))
        )
    )
}
