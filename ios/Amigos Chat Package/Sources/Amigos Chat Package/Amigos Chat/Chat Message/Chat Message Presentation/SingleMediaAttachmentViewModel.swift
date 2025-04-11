//
//  SingleMediaAttachmentViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 11/04/2025.
//

import SwiftUI

public enum SingleAttachmentType: Equatable, Hashable {
    case image(ImageAttachment)
    case video(VideoAttachment)

    var url: URL {
        switch self {
        case let .image(imageAttachment):
            return imageAttachment.imageUrl
        case let .video(videoAttachment):
            return videoAttachment.url
        }
    }

    var type: MediaAttachmentType {
        switch self {
        case .image:
            return .photo
        case .video:
            return .video
        }
    }
}

public final class SingleMediaAttachmentViewModel: ObservableObject {

    @Published var attachment: SingleAttachmentType

    @Published var selectedSingleAttachment: MediaAttachment?

    let author: LocalUser
    let videoPreviewLoader: PreviewVideoLoader
    let imageLoader: ImageLoader
    let imageCDN: ImageCDNhandler

    public init(
        attachment: SingleAttachmentType,
        author: LocalUser,
        videoPreviewLoader: PreviewVideoLoader,
        imageLoader: ImageLoader,
        imageCDN: ImageCDNhandler
    ) {
        self.attachment = attachment
        self.author = author
        self.videoPreviewLoader = videoPreviewLoader
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
    }

    @MainActor func presentMediaAttachment() {
        self.selectedSingleAttachment = toMediaAttachment()
    }
}

extension SingleMediaAttachmentViewModel {

    func toMediaAttachment() -> MediaAttachment {
        MediaAttachment(
            imageLoader: imageLoader,
            imageCDN: imageCDN,
            videoPreviewLoader: videoPreviewLoader,
            url: attachment.url,
            type: attachment.type
        )
    }
}
