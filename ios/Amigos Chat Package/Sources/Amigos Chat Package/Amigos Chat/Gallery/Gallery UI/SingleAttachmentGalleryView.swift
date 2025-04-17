//
//  SingleAttachmentGalleryView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/02/2025.
//

import SwiftUI
import AVKit

struct SingleAttachmentGalleryView: View {

    @StateObject var viewModel: SingleAttachmentViewModel

    @Binding var isPresented: Bool

    var animation: Namespace.ID

    init(
        isPresented: Binding<Bool>,
        viewModel: SingleAttachmentViewModel,
        animation: Namespace.ID = Namespace().wrappedValue
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.animation = animation
        _isPresented = isPresented

    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .matchedGeometryEffect(id: "header-animation", in: animation)
                .zIndex(1)
            mediaView
                .matchedTransitionSourceIfAvailable(sourceID: viewModel.attachment.url, animation: animation)
        }
        .background(Color.black)
        .statusBarHidden(false)

        .sheet(isPresented: $viewModel.attachmentToShare.toBoolBinding) {
            let items = [viewModel.attachmentToShare].compactMap { $0 }
            ShareActivityView(activityItems: items)
        }
    }
}

extension SingleAttachmentGalleryView {

    private var headerView: some View {
        HStack {
            Button {
                isPresented.toggle()
            } label: {
                Image(systemName: "xmark")
                    .customizable()
                    .frame(width: 16, height: 16)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(.white))
            }
            .frame(width: 20, height: 20)
            .padding(.horizontal, 16)

            Spacer()

            Text(viewModel.author.name)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Button {
                Task {
                    await viewModel.downloadAttachment()
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .customizable()
                    .frame(width: 20, height: 20)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(.white))
                    .padding(.top, -2)
            }
            .frame(width: 20, height: 20)
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
        .background(Color.black.opacity(0.6))
    }

    private var mediaView: some View {
        Group {
            switch viewModel.type {
            case .photo:
                zoomableImageView

            case .video:
                videoPlayer
            }
        }
    }

    private var zoomableImageView: some View {
        VStack {
            ZoomableScrollView {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(contentMode: .fit)
                        .allowsHitTesting(false)
                        .scaleEffect(1.0001) // Needed because of SwiftUI sometimes incorrectly displaying landscape images.
                        .clipped()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private var videoPlayer: some View {
        Group {
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .onAppear {
                        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            }
        }
    }
}

#Preview {
    SingleAttachmentGalleryView(
        isPresented: .constant(true),
        viewModel: SingleAttachmentViewModel(
            author: LocalUser(id: UUID(), name: "Ilon"),
            attachment: MediaAttachment(
                imageLoader: DefaultImageLoader(),
                imageCDN: MockImageCDN(),
                videoPreviewLoader: DefaultPreviewVideoLoader(),
                url: VideoURLExamples.example1,
                type: .video,
                uploadingState: nil
            )
        )
    )
}

#Preview {
    SingleAttachmentGalleryView(
        isPresented: .constant(true),
        viewModel: SingleAttachmentViewModel(
            author: LocalUser(id: UUID(), name: "Ilon"),
            attachment: MediaAttachment(
                imageLoader: DefaultImageLoader(),
                imageCDN: MockImageCDN(),
                videoPreviewLoader: DefaultPreviewVideoLoader(),
                url: ImageURLExamples.portraitImageUrl,
                type: .photo,
                uploadingState: nil
            )
        )
    )
}
