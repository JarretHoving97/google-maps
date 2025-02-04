//
//  URLSessionImageLoader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import Foundation
import UIKit

/// Loads images with URLSession.
public class DefaultImageLoader: ImageLoader {

    public init() {}

    /// Method to load a single image using URLRequest
    public func loadImage(using urlRequest: URLRequest, cachingKey: String?, completion: @escaping ((Result<UIImage, any Error>) -> Void)) {
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "ImageLoadingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])))
                return
            }

            completion(.success(image))
        }.resume()
    }

    /// Method to load a single image using a URL and optional resizing
    public func loadImage(url: URL?, imageCDN: any ImageCDNhandler, resize: Bool, preferredSize: CGSize?, completion: @escaping ((Result<UIImage, any Error>) -> Void)) {
        guard let url = url else {
            completion(.failure(NSError(domain: "ImageLoadingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, var image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "ImageLoadingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])))
                return
            }

            /// Resize the image if needed
            if resize, let preferredSize = preferredSize {
                image = self.resizeImage(image: image, targetSize: preferredSize)
            }

            completion(.success(image))
        }.resume()
    }

    /// Method to load multiple images
    public func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: any ImageCDNhandler,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        var loadedImages: [UIImage] = []
        let group = DispatchGroup()

        for url in urls {
            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }

                if let data = data, let image = UIImage(data: data) {
                    if loadThumbnails {
                        let resizedImage = self.resizeImage(image: image, targetSize: thumbnailSize)
                        loadedImages.append(resizedImage)
                    } else {
                        loadedImages.append(image)
                    }
                }
            }.resume()
        }

        group.notify(queue: .main) {
            /// If no images were loaded, use placeholders
            if loadedImages.isEmpty {
                completion(placeholders)
            } else {
                completion(loadedImages)
            }
        }
    }

    /// Helper method to resize an image
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        /// Determine the scale factor to maintain the aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
