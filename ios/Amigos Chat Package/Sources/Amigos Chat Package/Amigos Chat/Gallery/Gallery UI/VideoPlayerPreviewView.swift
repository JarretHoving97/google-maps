//
//  VideoPlayer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 31/01/2025.
//

import AVKit
import SwiftUI

class LazyLoadVideoPreviewViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var error: Error?

    private let attachment: MediaAttachment

    init(attachment: MediaAttachment) {
        self.attachment = attachment
    }

    func loadPreviewImage() {
        guard image == nil else { return }

        attachment.videoPreviewLoader.loadPreviewForVideo(at: attachment.url) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(image):
                    self.image = image
                case let .failure(error):
                    self.error = error
                }
            }
        }
    }
}

struct PreviewVideoView: View {

    @StateObject var previewImageLoader: LazyLoadVideoPreviewViewModel

    init(attachment: MediaAttachment) {
        _previewImageLoader = StateObject(wrappedValue: LazyLoadVideoPreviewViewModel(attachment: attachment))
    }

    var body: some View {
        Group {
            if let previewImage = previewImageLoader.image {
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

            }
        }
        .onAppear {
            previewImageLoader.loadPreviewImage()

        }
    }
}

struct VideoPlayerPreviewView: View {

    let attachment: MediaAttachment
    let author: LocalUser

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
