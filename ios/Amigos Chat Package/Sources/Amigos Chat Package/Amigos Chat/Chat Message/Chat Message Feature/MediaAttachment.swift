//
//  MediaAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import Foundation
import UIKit.UIImage

struct MediaAttachment {
    let imageLoader: ImageLoader
    let imageCDN: ImageCDNhandler
    let videoPreviewLoader: PreviewVideoLoader
    let url: URL
    let type: MediaAttachmentType
    let uploadingState: UploadingState?

    func generateThumbnail(
        resize: Bool,
        preferredSize: CGSize,
        uploadingState: UploadingState?,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        if type == .image {
            imageLoader.loadImage(
                url: url,
                imageCDN: imageCDN,
                resize: resize,
                preferredSize: preferredSize,
                completion: completion
            )
        } else if type == .video {
            videoPreviewLoader.loadPreviewForVideo(
                at: url,
                completion: completion
            )
        }
    }
}

enum MediaAttachmentType {
    case image
    case video
}
