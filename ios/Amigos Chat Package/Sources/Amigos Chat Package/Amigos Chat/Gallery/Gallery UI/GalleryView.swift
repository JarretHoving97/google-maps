//
//  GalleryView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 30/01/2025.
//

import SwiftUI

struct GalleryView: View {

    @ObservedObject private var viewModel: GalleryViewModel
    @State private var presentedAttachment: MediaAttachment?

    @Namespace private var animation

    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        scrollableContent
            .overlay {
                if presentedAttachment != nil {
                    attachmentDetailView
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: presentedAttachment)
    }

    private var scrollableContent: some View {
        GeometryReader { reader in
            ZStack {
                VStack {
                    headerView
                        .frame(height: 30)
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(0..<viewModel.attachments.count, id: \.self) { index in
                                    let attachment = viewModel.attachments[index]
                                    attachmentView(
                                        for: attachment,
                                        onImageLoaded: {_ in },
                                        width: reader.size.width,
                                        height: reader.size.height
                                        )
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                presentedAttachment = attachment
                                            }

                                        }

                                    .tag(index)
                                    .overlay {
                                        selectableOverlay(index: index)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(viewModel.selected, anchor: .top)
                        }
                    }
                }
                .ignoresSafeArea(edges: [.bottom])
                .statusBarHidden(false)

                VStack {
                    Spacer()
                    footerView
                        .background(.white)
                        .offset(y: viewModel.showSelectedState ? 0 : 80)
                }
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
        onImageLoaded: @escaping ((UIImage) -> Void),
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        VStack {
            if attachment.type == .photo {
                VStack {
                    Spacer()
                    LazyLoadImage(
                        source: attachment,
                        shouldSetFrame: false,
                        resize: true,
                        width: width,
                        height: height,
                        onImageLoaded: onImageLoaded
                    )
                    .aspectRatio(contentMode: .fit)
                    Spacer()
                }
                .frame(
                    width: width,
                    height: height
                )
                .background(Color.gray.opacity(0.2))
            } else {
                VideoPlayerPreviewView(
                    attachment: attachment,
                    author: viewModel.author
                )
                .frame(
                    width: width,
                    height: height
                )
            }

            Divider()
        }
        .matchedGeometryEffect(id: attachment.url, in: animation, isSource: true)
    }

    private var headerView: some View {
        Group {
            if viewModel.showSelectedState {
                selectedHeaderView
                    .matchedGeometryEffect(id: "header-animation", in: animation, isSource: true)
            } else {
                regularHeaderView
            }
        }
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
        ZStack {
            HStack {
                Button {
                    viewModel.toggleSelectAllAttachments()
                } label: {
                    Text(viewModel.selectAllItemsLabel)
                        .font(.body)
                }
                .padding()
                .foregroundStyle(Color(.purple))

                Spacer()
            }

            titleView

            HStack {
                Spacer()
                Button(viewModel.doneLabel) {
                    withAnimation(.spring(response: 0.4)) {
                        viewModel.selectedIndices.removeAll()
                        viewModel.showSelectedState = false
                    }
                }
                .font(Font.custom(size: 16, weight: .semiBold))
                .foregroundColor(Color(.darkText))
                .padding()
            }
        }
    }

    private var regularHeaderView: some View {
        ZStack {
            HStack {
                Button {
                    viewModel.isShown = false
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color(.purple))
                }

                .frame(width: 20, height: 20)
                .padding(.horizontal, 26)
                Spacer()
            }

            titleView

            HStack {
                Spacer()

                Menu {
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            viewModel.showSelectedState.toggle()
                        }

                    } label: {
                        Label(viewModel.selectAttachmentsLabel, systemImage: "checkmark.circle")

                    }
                } label: {
                    ZStack {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .foregroundStyle(Color(.purple))
                            .frame(width: 20, height: 4)

                    }
                    .frame(width: 20, height: 20)

                }

                .padding(.horizontal, 26)
                .foregroundColor(Color(.darkText))

            }
        }

    }

    private var titleView: some View {
        VStack {
            Text(viewModel.author.name)
                .font(Font.custom(size: 16, weight: .medium))

            Text(viewModel.attachmentsLabel)
                .font(Font.custom(size: 10, weight: .regular))
        }
    }

    private var footerView: some View {
        HStack(alignment: .center) {

            Button(action: {
                Task {
                    await viewModel.downloadSelectedAttachments()
                }

            }, label: {
                Image(systemName: "square.and.arrow.up")
                    .customizable()
                    .frame(width: 18, height: 22)
            })
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(Color(.darkText))
            .disabled(viewModel.selectedIndices.count == 0)
            .opacity(viewModel.selectedIndices.count > 0 ?  1 : 0.6)
            .sheet(isPresented: $viewModel.presentActivitySheet) {
                ShareActivityView(activityItems: viewModel.shareableContent)
            }

            Spacer()

            Text(viewModel.selectedItemsLabel)
                .font(Font.custom(size: 16, weight: .regular))
                .opacity(viewModel.attachments.count > 1 ? 1 : 0)

            Spacer()

            Spacer()

        }
        .foregroundColor(Color(.darkText))
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
