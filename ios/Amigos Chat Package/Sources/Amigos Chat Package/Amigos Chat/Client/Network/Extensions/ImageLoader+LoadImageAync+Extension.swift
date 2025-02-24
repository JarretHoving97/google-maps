//
//  ImageLoader+LoadImageAync+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 11/02/2025.
//

import Foundation
import UIKit.UIImage

extension ImageLoader {
    // Async wrapper for the loadImage method
    func loadImageAsync(
        url: URL,
        imageCDN: ImageCDNhandler,
        resize: Bool,
        preferredSize: CGSize?
    ) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            loadImage(
                url: url,
                imageCDN: imageCDN,
                resize: resize,
                preferredSize: preferredSize
            ) { result in
                switch result {
                case .success(let image):
                    continuation.resume(returning: image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
