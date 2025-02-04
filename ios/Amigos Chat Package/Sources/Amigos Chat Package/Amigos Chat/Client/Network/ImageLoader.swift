//
//  ImageLoader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import Foundation
import UIKit

/// Copied form `ImageLoading` from streams API
/// To eventually extend `NukeImageLoader` to `ImageLoader`.
/// This way we can keep the fast imageloading behaviour as before by injecting `NukeImageLoader`
/// Adn we won't be couple to stream types
public protocol ImageLoader: AnyObject {

    func loadImage(
        using urlRequest: URLRequest,
        cachingKey: String?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    )

    /// Loads an image from the provided url.
    /// - Parameters:
    ///   - url: The URL to load the images from.
    ///   - imageCDN: The imageCDN to be used
    ///   - resize: whether the image should be resized.
    ///   - preferredSize: if resized, what should be the preferred size.
    ///   - completion: Completion that gets called when all the images finish downloading
    func loadImage(
        url: URL?,
        imageCDN: ImageCDNhandler,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    )

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDNhandler,
        completion: @escaping (([UIImage]) -> Void))
}

/// Same goes for here:
/// a Copy from `ImageCDN` protocol.
/// So we can extend `StreamImageCDN` to it and inject.
public protocol ImageCDNhandler {

    /// Customised (filtered) key for image cache.
    /// - Parameter imageURL: URL of the image that should be customised (filtered).
    /// - Returns: String to be used as an image cache key.
    func cachingKey(forImage url: URL) -> String

    /// Prepare and return a `URLRequest` for the given image `URL`
    /// This function can be used to inject custom headers for image loading request.
    func urlRequest(forImage url: URL) -> URLRequest

    /// Enhance image URL with size parameters to get thumbnail
    /// - Parameters:
    ///   - originalURL: URL of the image to get the thumbnail for.
    ///   - preferredSize: The requested thumbnail size.
    ///
    /// Use view size in points for `preferredSize`, point to pixel ratio (scale) of the device is applied inside of this function.
    func thumbnailURL(originalURL: URL, preferredSize: CGSize) -> URL
}
