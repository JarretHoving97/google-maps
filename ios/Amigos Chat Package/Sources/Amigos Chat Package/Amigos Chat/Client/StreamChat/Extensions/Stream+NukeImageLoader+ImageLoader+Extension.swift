//
//  NukeImageLoader+ImageLoader+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import StreamChatSwiftUI
import Foundation
import UIKit

extension NukeImageLoader: ImageLoader {

    public func loadImages(from urls: [URL], placeholders: [UIImage], loadThumbnails: Bool, thumbnailSize: CGSize, imageCDN: any ImageCDNhandler, completion: @escaping (([UIImage]) -> Void)) {
        loadImages(from: urls, placeholders: placeholders, loadThumbnails: loadThumbnails, thumbnailSize: thumbnailSize, imageCDN: imageCDN as! ImageCDN, completion: completion)
    }

    public func loadImage(url: URL?, imageCDN: any ImageCDNhandler, resize: Bool, preferredSize: CGSize?, completion: @escaping ((Result<UIImage, any Error>) -> Void)) {
        loadImage(url: url, imageCDN: imageCDN as! ImageCDN, resize: resize, preferredSize: preferredSize, completion: completion)
    }
}
