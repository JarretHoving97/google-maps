//
//  LazyLoadImageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import SwiftUI

class LazyLoadImageViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var error: Error?

    func loadImage(from source: MediaAttachment, resize: Bool, preferredSize: CGSize) {
        guard image == nil else { return }

        source.generateThumbnail(
            resize: resize,
            preferredSize: preferredSize,
            uploadingState: source.uploadingState
        ) { result in
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

struct LazyLoadImage: View, Equatable {
    @StateObject private var loader = LazyLoadImageViewModel()

    let source: MediaAttachment
    var shouldSetFrame: Bool = true
    var resize: Bool = true
    let width: CGFloat
    let height: CGFloat

    var onImageLoaded: (UIImage) -> Void = { _ in /* Default implementation. */ }

    static func == (lhs: LazyLoadImage, rhs: LazyLoadImage) -> Bool {
        lhs.source.url == rhs.source.url &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
            if let image = loader.image {
                imageView(for: image)
            } else if loader.error == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            }
        }
        .animation(.easeIn(duration: 0.1), value: loader.image)
        .onAppear {
            loader.loadImage(from: source, resize: resize, preferredSize: CGSize(width: width, height: height))
        }
        .onChange(of: loader.image) { newImage in
            if let newImage = newImage {
                onImageLoaded(newImage)
            }
        }
    }

    func imageView(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .aspectRatio(contentMode: .fill)
            .frame(width: shouldSetFrame ? width : nil, height: shouldSetFrame ? height : nil)
            .allowsHitTesting(false)
            .scaleEffect(1.0001) // Needed because of SwiftUI sometimes incorrectly displaying landscape images.
            .clipped()
    }
}
