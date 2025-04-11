//
//  VideoPlayer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 31/01/2025.
//

import AVKit
import SwiftUI

struct PreviewVideoView: View {

    let attachment: MediaAttachment

    @State var previewImage: UIImage?
    @State var error: Error?

    var body: some View {
        if let previewImage = previewImage {
            Image(uiImage: previewImage)
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fit)
                .allowsHitTesting(false)
        } else {
            ZStack {
                Color(.secondarySystemBackground)
                ProgressView()
            }
            .onAppear {
                attachment.videoPreviewLoader.loadPreviewForVideo(at: attachment.url) { result in
                    switch result {
                    case let .success(image):
                        self.previewImage = image
                    case let .failure(error):
                        self.error = error
                    }
                }
            }
        }
    }
}

struct VideoPlayerPreviewView: View {

    let attachment: MediaAttachment
    let author: LocalUser

    @State private var loadedImage: UIImage?

    init(attachment: MediaAttachment, author: LocalUser) {
        self.attachment = attachment
        self.author = author
    }

    var body: some View {
        VStack {
            ZStack {
                PreviewVideoView(attachment: attachment)

                ZStack {
                    Circle()
                        .fill(Color(.white))
                        .frame(width: 80, height: 80)
                        .modifier(ShadowModifier())

                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.black)
                        .padding(.leading, 8)
                }
            }
        }
        .overlay {
            EmptyView()
        }
        .disabled(false)
    }
}

#Preview {
    VideoPlayerPreviewView(
        attachment: MediaAttachment(
            imageLoader: DefaultImageLoader(),
            imageCDN: MockImageCDN(),
            videoPreviewLoader: DefaultPreviewVideoLoader(),
            url: VideoURLExamples.example1,
            type: .video,
            uploadingState: .none
        ), author: LocalUser(id: UUID(), name: "Ilon")
    )
}
