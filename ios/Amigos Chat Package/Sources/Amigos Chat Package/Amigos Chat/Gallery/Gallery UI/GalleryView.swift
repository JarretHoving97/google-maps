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
            .background(Color("Grey Light"))
            .overlay {
                if presentedAttachment != nil {
                    attachmentDetailView
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: presentedAttachment)
    }

    let dividerHeight: CGFloat = 16

    private var scrollableContent: some View {
        GeometryReader { reader in
            VStack(spacing: 0) {
                headerView

                Divider()
                    .frame(height: 2)
                    .overlay(Color("Grey Light"))

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(0..<viewModel.attachments.count, id: \.self) { index in
                                let attachment = viewModel.attachments[index]
                                attachmentView(
                                    for: attachment,
                                    width: reader.size.width,
                                    height: reader.size.height - dividerHeight
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

                                Divider()
                                    .frame(height: dividerHeight)
                                    .overlay(Color("Grey Light"))
                            }
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(viewModel.selected, anchor: .top)
                    }
                }
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
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            VStack {
                Spacer()

                if attachment.type == .photo {
                    LazyLoadImage(
                        source: attachment,
                        shouldSetFrame: false,
                        resize: true,
                        width: width,
                        height: height
                    )
                    .aspectRatio(contentMode: .fit)
                } else {
                    VideoPlayerPreviewView(
                        attachment: attachment,
                        author: viewModel.author
                    )
                }
                Spacer()
            }
            .frame(
                width: width,
                height: height
            )
            .background(Color("Grey Light"))
        }
        .matchedGeometryEffect(id: attachment.url, in: animation, isSource: true)
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
