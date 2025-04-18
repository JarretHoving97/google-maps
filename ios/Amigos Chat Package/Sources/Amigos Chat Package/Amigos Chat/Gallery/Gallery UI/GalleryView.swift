//
//  GalleryView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 30/01/2025.
//

import SwiftUI

struct GalleryView: View {

    @StateObject private var viewModel: GalleryViewModel
    @State private var presentedAttachment: MediaAttachment?
    @Namespace private var animation

    init(viewModel: GalleryViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        scrollableContent
            .background(Color("Grey Light"))
            .fullScreenCover(isPresented: $presentedAttachment.toBoolBinding) {
                SingleAttachmentGalleryView(
                    isPresented: $presentedAttachment.toBoolBinding,
                    viewModel: SingleAttachmentViewModel(
                        author: viewModel.author,
                        attachment: presentedAttachment!,
                        image: viewModel.loadedImages[presentedAttachment!.url]
                    ),
                    animation: animation
                )
                    .navigationTransitionIfAvailable(
                        sourceID: presentedAttachment!.url,
                        animation: animation
                    )
            }
    }

    private var scrollableContent: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                /*  ScrollViewReader { proxy in */
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<viewModel.attachments.count, id: \.self) { index in
                            let attachment = viewModel.attachments[index]
                            attachmentView(
                                for: attachment,
                                onImageLoad: { [weak viewModel] image in
                                    guard viewModel?.loadedImages[attachment.url] == nil else { return }
                                    viewModel?.loadedImages[attachment.url] = image
                                }
                            )
                            .matchedTransitionSourceIfAvailable(
                                sourceID: attachment.url,
                                animation: animation
                            )
                            .onTapGesture {
                                presentedAttachment = attachment
                            }
                            .tag(index)
                            .overlay {
                                selectableOverlay(index: index)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // footerheight is 44
                .padding(.bottom, viewModel.showSelectedState ? 44 : 0)
            }
            VStack {
                Spacer()
                footerView
                    .background(.white)
                    .offset(y: viewModel.showSelectedState ? 0 : 80)
            }
        }
    }

    var attachmentDetailView: some View {
        SingleAttachmentGalleryView(
            isPresented: $presentedAttachment.toBoolBinding,
            viewModel: SingleAttachmentViewModel(
                author: viewModel.author,
                attachment: presentedAttachment!
            ),
            animation: animation
        )
    }

    @ViewBuilder func attachmentView(
        for attachment: MediaAttachment,
        onImageLoad: @escaping (UIImage) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            VStack {
                if attachment.type == .photo {
                    GalleryImageView(
                        author: LocalUser(id: UUID(), name: "Ilon"),
                        attachment: ImageAttachment(imageUrl: attachment.url, uploadingState: nil),
                        loader: attachment.imageLoader,
                        imageCDN: attachment.imageCDN
                    )

                } else {
                    VideoPlayerPreviewView(
                        attachment: attachment,
                        author: viewModel.author
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color("Grey Light"))
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            if viewModel.showSelectedState {
                selectedHeaderView
                    .matchedGeometryEffect(id: "header-animation", in: animation, isSource: true)
            } else {
                regularHeaderView
            }
        }
        .frame(height: 44)
        .background(Color.white)
        .animation(nil, value: viewModel.showSelectedState)
    }

    @ViewBuilder private func selectableOverlay(index: Int) -> some View {
        Group {
            if viewModel.showSelectedState {
                ZStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Button {
                                viewModel.select(index: index)
                            } label: {
                                CheckboxView(
                                    selected: viewModel.selectedIndices.contains(index)
                                )
                            }
                            .padding()
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(!viewModel.selectedIndices.contains(index) ? 0.1 : 0.3 ))
                    .onTapGesture {
                        viewModel.select(index: index)
                    }
                }
            }
        }
    }

    private var selectedHeaderView: some View {
        HStack {
            HStack {
                Button {
                    viewModel.toggleSelectAllAttachments()
                } label: {
                    Text(viewModel.selectAllItemsLabel)
                        .font(.body)
                }
                .foregroundStyle(Color(.purple))

                Spacer()
            }

            titleView

            HStack {
                Spacer()

                Button {
                    withAnimation(.spring(response: 0.4)) {
                        viewModel.selectedIndices.removeAll()
                        viewModel.showSelectedState = false
                    }
                } label: {
                    Text(viewModel.doneLabel)
                        .font(.subheadline)
                        .foregroundColor(Color("Purple"))
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(.horizontal, 16)
    }

    private var regularHeaderView: some View {
        HStack {
            HStack {
                Button {
                    viewModel.isShown = false
                } label: {
                    Image(systemName: "xmark")
                        .customizable()
                        .frame(width: 16, height: 16)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(.purple))
                }
                .frame(width: 20, height: 20)

                Spacer()
            }

            titleView

            HStack {
                Spacer()

                Button {
                    withAnimation(.spring(response: 0.4)) {
                        viewModel.showSelectedState.toggle()
                    }
                } label: {
                    Text(viewModel.selectAttachmentsLabel)
                        .font(.subheadline)
                        .foregroundColor(Color("Purple"))
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(.horizontal, 16)
    }

    private var titleView: some View {
        Text(viewModel.author.name)
            .font(.headline)
            .foregroundStyle(Color("Grey Dark"))
    }

    private var footerView: some View {
        HStack {
            Button(action: {
                Task {
                    await viewModel.downloadSelectedAttachments()
                }
            }, label: {
                Image(systemName: "square.and.arrow.up")
                    .customizable()
                    .frame(width: 20, height: 20)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("Purple"))
            })
            .disabled(viewModel.selectedIndices.count == 0)
            .opacity(viewModel.selectedIndices.count > 0 ?  1 : 0.3)
            .sheet(isPresented: $viewModel.presentActivitySheet) {
                ShareActivityView(activityItems: viewModel.shareableContent)
            }

            Spacer()

            Text(viewModel.selectedItemsLabel)
                .font(.body)
                .foregroundColor(Color("Grey Dark"))
                .opacity(viewModel.attachments.count > 1 ? 1 : 0)

            Spacer()

            // Keeps the text centered
            Color.clear
                .frame(width: 20)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
}

#Preview {
    GalleryView(
        viewModel: GalleryViewModel(
            isShown: .constant(true),
            attachments: [
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: VideoURLExamples.example1,
                    type: .video,
                    uploadingState: .none
                ),
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.portraitImageUrl,
                    type: .photo,
                    uploadingState: .none
                ),
                MediaAttachment(
                    imageLoader: DefaultImageLoader(),
                    imageCDN: MockImageCDN(),
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: ImageURLExamples.landscapeImageUrl,
                    type: .photo,
                    uploadingState: .none
                )
            ],
            author: LocalUser(id: UUID(), name: "Ilon")
        )
    )
}

class GalleryImageViewViewModel: ObservableObject {
    @Published var aspectRatio: CGFloat?
    @Published var maxWidth: CGFloat
    @Published var maxHeight: CGFloat

    let loader: ImageLoader
    let imageCDN: ImageCDNhandler
    let attachment: ImageAttachment

    init(
        aspectRatio: CGFloat? = nil,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        loader: ImageLoader,
        imageCDN: ImageCDNhandler,
        attachment: ImageAttachment
    ) {
        self.aspectRatio = aspectRatio
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.loader = loader
        self.imageCDN = imageCDN
        self.attachment = attachment
    }
}

public struct GalleryImageView: View {

    @StateObject var viewModel: GalleryImageViewViewModel

    init(
        author: LocalUser,
        attachment: ImageAttachment,
        loader: ImageLoader,
        imageCDN: ImageCDNhandler,
        maxHeight: CGFloat = UIScreen.main.bounds.size.height * 0.8, // 80% of screen height
        maxWidth: CGFloat = UIScreen.main.bounds.size.width
    ) {
        _viewModel = StateObject(
            wrappedValue: GalleryImageViewViewModel(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                loader: loader,
                imageCDN: imageCDN,
                attachment: attachment
            )
        )
    }

    public var body: some View {
        ZStack {
            LazyLoadImage(
                source: MediaAttachment(
                    imageLoader: viewModel.loader,
                    imageCDN:  viewModel.imageCDN,
                    videoPreviewLoader: DefaultPreviewVideoLoader(),
                    url: viewModel.attachment.imageUrl,
                    type: .photo,
                    uploadingState: nil
                ),
                shouldSetFrame: false,
                resize: false,
                width: 0,
                height: 0,
                onImageLoaded: { image in
                    guard viewModel.aspectRatio == nil else { return }
                    viewModel.aspectRatio = image.size.width / image.size.height
                }
            )

        }
        .aspectRatio(contentMode: .fit)
        .frame(
            width: min(viewModel.maxWidth, (viewModel.aspectRatio ?? 1) * viewModel.maxHeight), /// Constrain width
            height: min(viewModel.maxHeight, viewModel.maxWidth / (viewModel.aspectRatio ?? 1)) /// Constrain height
        )
        .contentShape(Rectangle()) /// Needed to recognize tap gesture
    }
}
