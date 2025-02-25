//
//  MultiMediaView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI
import StreamChatSwiftUI

class MultiMedaViewModel: ObservableObject {
    @Published var showMediaGallery: Bool = false
    @Published var selectedIndex: Int = 0
}

public struct MultiMediaView: View {

    var sources: [MediaAttachment]
    let isSentByCurrentUser: Bool
    let user: LocalUser
    let width: CGFloat

    @State private var selectedIndex: Int?
    
    @StateObject private var viewModel = MultiMedaViewModel()

    init(user: LocalUser, sources: [MediaAttachment], isSentByCurrentUser: Bool = false, width: CGFloat = .messageWidth) {
        self.sources = sources
        self.isSentByCurrentUser = isSentByCurrentUser
        self.width = width
        self.user = user
    }

    public var body: some View {
        let spacing: CGFloat = 2

        Group {
            if sources.count == 1 {
                imageView(
                    with: sources[0],
                    width: width,
                    height: height(width: width)
                )
            } else if sources.count == 2 {
                HStack(spacing: spacing) {
                    imageView(
                        with: sources[0],
                        width: width / 2,
                        height: height(width: width)
                    )
                    imageView(
                        with: sources[1],
                        width: width / 2,
                        height: height(width: width)
                    )
                }
            } else if sources.count == 3 {

                HStack(spacing: spacing) {
                    imageView(
                        with: sources[0],
                        width: width / 2,
                        height: height(width: width)
                    )
                    VStack(spacing: spacing) {
                        imageView(
                            with: sources[1],
                            width: width / 2,
                            height: height(width: width / 2)
                        )
                        imageView(
                            with: sources[2],
                            width: width / 2,
                            height: height(width: width / 2)
                        )
                    }
                    .frame(height: height(width: width))
                }

            } else if sources.count >= 4 {

                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        imageView(
                            with: sources[0],
                            width: width / 2,
                            height: height(width: width / 2)
                        )
                        imageView(
                            with: sources[1],
                            width: width / 2,
                            height: height(width: width / 2)
                        )
                    }

                    HStack(spacing: spacing) {
                        imageView(
                            with: sources[2],
                            width: width / 2,
                            height: height(width: width / 2)
                        )

                        imageView(
                            with: sources[3],
                            width: width / 2,
                            height: height(width: width / 2)
                        )
                        .overlay {
                            if sources.count > 4 {
                                ZStack {
                                    Color.black
                                        .opacity(0.3)
                                    Text("+\(sources.count - 4)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .onTapGesture(perform: { mediaFileTapped(attachment: sources[3])})
                    }
                }
            }
        }
        .background(isSentByCurrentUser ? Color(.purple) : Color.white)
        .frame(width: width, height: height(width: width))
    }

    ///  The computed height as 3/4 of the width
    private func height(width: CGFloat) -> CGFloat {
        3 * width / 4
    }

    @ViewBuilder func imageView(with source: MediaAttachment, width: CGFloat, height: CGFloat) -> some View {

        Group {
            switch source.type {
            case .photo:
                LazyLoadImage(
                    source: source,
                    width: width,
                    height: height
                )

            case .video:
                ZStack {
                    LazyLoadImage(
                        source: source,
                        width: width,
                        height: height
                    )
                    VStack {
                        VideoPlayIcon()
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            mediaFileTapped(attachment: source)
        }
        .withUploadingStateIndicator(
            for: source.uploadingState,
            url: source.url
        )
        .fullScreenCover(isPresented: $viewModel.showMediaGallery) {
            GalleryView(
                viewModel: GalleryViewModel(
                    isShown: $viewModel.showMediaGallery,
                    attachments: sources,
                    author: user,
                    selected: viewModel.selectedIndex
                )
            )
        }
    }

    func mediaFileTapped(attachment: MediaAttachment) {
        selectedIndex = sources.firstIndex(of: attachment) ?? 0
        viewModel.selectedIndex = sources.firstIndex(of: attachment) ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.showMediaGallery.toggle()
        }
    }
}

#Preview {
    VStack {
        MultiMediaView(
            user: LocalUser(id: UUID(), name: "Ilon"), sources: [
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.portraitImageUrl,
                    type: .photo, uploadingState: .init(localFileURL: ImageURLExamples.portraitImageUrl, state: .uploading(progress: 0.2)))
            ], isSentByCurrentUser: true
        )
        MultiMediaView(
            user: LocalUser(id: UUID(), name: "Ilon"),
            sources: [
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.portraitImageUrl,
                    type: .photo,
                    uploadingState: .some(
                        UploadingState(localFileURL: ImageURLExamples.portraitImageUrl, state: .uploading(progress: 0.88))
                    )
                ),
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.portraitImageUrl,
                    type: .photo,
                    uploadingState: nil),
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.portraitImageUrl,
                    type: .photo,
                    uploadingState: nil)
            ],
            isSentByCurrentUser: true
        )
        MultiMediaView(
            user: LocalUser(id: UUID(), name: "Ilon"),
            sources: [
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: VideoURLExamples.example1,
                    type: .video,
                    uploadingState: .some(
                        UploadingState(
                            localFileURL: VideoURLExamples.example1,
                            state: .uploadingFailed
                        )
                    )
                ),
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.portraitImageUrl,
                    type: .photo,
                    uploadingState: nil),
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.portraitImageUrl,
                    type: .photo,
                    uploadingState: nil),
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: VideoURLExamples.example1,
                    type: .video,
                    uploadingState: nil)
            ]
        )
    }
}
