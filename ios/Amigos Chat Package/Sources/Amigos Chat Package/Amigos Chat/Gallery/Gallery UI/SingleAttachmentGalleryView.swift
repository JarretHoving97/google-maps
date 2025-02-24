//
//  SingleAttachmentGalleryView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/02/2025.
//

import SwiftUI
import AVKit

struct SingleAttachmentGalleryView: View {

    @ObservedObject var viewModel: SingleAttachmentViewModel

    @Binding var isPresented: Bool

    var animation: Namespace.ID

    init(isPresented: Binding<Bool>, viewModel: SingleAttachmentViewModel, animation: Namespace.ID = Namespace().wrappedValue) {
        self.viewModel = viewModel
        self.animation = animation
        _isPresented = isPresented

    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .matchedGeometryEffect(id: "header-animation", in: animation)
                .zIndex(1)
            mediaView
                .matchedGeometryEffect(id: viewModel.attachment.url, in: animation)
                .ignoresSafeArea(edges: [.bottom])
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

            HStack {

                Button {
                    isPresented.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color(.white))
                }
                .frame(width: 20, height: 20)
                .padding(.horizontal, 26)

                Spacer()

                VStack {
                    Text(viewModel.author.name)
                        .font(Font.custom(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }

                Spacer()

                Button {
                    Task {
                        await viewModel.downloadAttachment()
                    }

                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 20)

                }
                .padding(.horizontal, 26)
            }
        }
        .frame(height: 30)
        .background(Color.black.opacity(0.4))
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
                    LazyLoadImage(
                        source: viewModel.attachment,
                        shouldSetFrame: false,
                        resize: true,
                        width: UIScreen.main.bounds.size.width,
                        height: UIScreen.main.bounds.size.height
                    )

                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
        }
    }

    private var videoPlayer: some View {
        Group {
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .onAppear {
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
