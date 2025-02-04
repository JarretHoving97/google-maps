//
//  LazyLoadImageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import SwiftUI

struct LazyLoadImage: View {

    @State private var image: UIImage?
    @State private var error: Error?

    let source: MediaAttachment

    var shouldSetFrame: Bool = true
    var resize: Bool = true
    let width: CGFloat
    let height: CGFloat

    var onImageLoaded: (UIImage) -> Void = { _ in /* Default implementation. */ }

    var body: some View {
        ZStack {
            if let image = image {
                imageView(for: image)
            } else if error == nil {
                ZStack {
                    Color(.grey)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
            }
        }
        .frame(width: width, height: height)
        .onAppear {
            guard image == nil else { return }

            source.generateThumbnail(
                resize: resize,
                preferredSize: CGSize(width: width, height: height), uploadingState: source.uploadingState) { result in
                    switch result {
                    case let .success(image):
                        self.image = image
                        onImageLoaded(image)
                    case let .failure(error):
                        self.error = error
                    }
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
