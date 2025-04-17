//
//  SingleMediaAttachmentView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 11/04/2025.
//

import SwiftUI

struct SingleMediaAttachmentView: View {

    @StateObject var viewModel: SingleMediaAttachmentViewModel
    let maxWidth: CGFloat

    @Namespace var animation

    init(
        viewModel: SingleMediaAttachmentViewModel,
        maxWidth: CGFloat = .messageWidth
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.maxWidth = maxWidth
    }

    var body: some View {
        attachmentView
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.presentMediaAttachment()
                    }
            )
            .fullScreenCover(isPresented: $viewModel.selectedSingleAttachment.toBoolBinding) {
                SingleAttachmentGalleryView(
                    isPresented: $viewModel.selectedSingleAttachment.toBoolBinding,
                    viewModel: SingleAttachmentViewModel(
                        author: viewModel.author,
                        attachment: viewModel.selectedSingleAttachment!
                    ),
                    animation: animation
                )
                .navigationTransitionIfAvailable(
                    sourceID: viewModel.selectedSingleAttachment!.url,
                    animation: animation
                )
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.selectedSingleAttachment)
    }

    private var attachmentView: some View {
        Group {
            switch viewModel.attachment {
            case let .image(imageAttachment):
                ImageAttachmentView(
                    author: viewModel.author,
                    attachment: imageAttachment,
                    loader: viewModel.imageLoader,
                    imageCDN: viewModel.imageCDN
                )
                .matchedTransitionSourceIfAvailable(
                    sourceID: imageAttachment.imageUrl,
                    animation: animation
                )

            case let .video(videoAttachment):
                VideoPreviewAttachmentView(
                    user: viewModel.author,
                    videoPreviewLoader: viewModel.videoPreviewLoader,
                    attachment: videoAttachment,
                    width: maxWidth
                )
                .matchedTransitionSourceIfAvailable(
                    sourceID: videoAttachment.url,
                    animation: animation
                )
            }
        }
    }
}
