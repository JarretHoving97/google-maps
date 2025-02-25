//
//  MediaAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import Foundation
import UIKit.UIImage

enum MediaAttachmentType {
    case photo
    case video
}

extension MediaAttachmentType {

    func toTranslatableType() -> Localized.AttachmentType {
        switch self {
        case .photo:
            return .photo
        case .video:
            return .video
        }
    }
}

struct MediaAttachment {
    let imageLoader: ImageLoader
    let imageCDN: ImageCDNhandler
    let videoPreviewLoader: PreviewVideoLoader
    let url: URL
    let type: MediaAttachmentType
    let uploadingState: UploadingState?

    init(
        imageLoader: ImageLoader,
        imageCDN: ImageCDNhandler,
        videoPreviewLoader: PreviewVideoLoader,
        url: URL,
        type: MediaAttachmentType,
        uploadingState: UploadingState? = nil
    ) {
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
        self.videoPreviewLoader = videoPreviewLoader
        self.url = url
        self.type = type
        self.uploadingState = uploadingState
    }

    func generateThumbnail(
        resize: Bool,
        preferredSize: CGSize,
        uploadingState: UploadingState?,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        if type == .photo {
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

extension MediaAttachment: Equatable {

    static func == (lhs: MediaAttachment, rhs: MediaAttachment) -> Bool {
        lhs.url == rhs.url
    }

    static func video(with url: URL, previewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader()) -> MediaAttachment {
        return MediaAttachment(
            imageLoader: DefaultImageLoader(),
            imageCDN: MockImageCDN(),
            videoPreviewLoader: previewLoader,
            url: url,
            type: .video
        )
    }
    
    enum MediaAttachmentError: Error {
        case convertingToDataFailed
        case itemProviderFailed
    }
    
    func download() async throws -> Any {
        try await AttachmentDownloader.downloadShareableActivity(from: self)
    }
}
