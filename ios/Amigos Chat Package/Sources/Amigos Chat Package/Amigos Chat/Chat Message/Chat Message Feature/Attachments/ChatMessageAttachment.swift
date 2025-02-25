//
//  AnyChatMessageAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

public struct LocationAttachment: Equatable, Hashable {
    let id: UUID
    let latitudeDouble: Double
    let longitudeDouble: Double
}

public enum LocalChatMessageAttachment: Hashable, Equatable {

    case image(ImageAttachment)
    case file(FileAttachment)
    case video(VideoAttachment)
    case link(LinkAttachment)
    case location(LocationAttachment)
    case notsupported

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .image(let attachment):
            hasher.combine("image")
            hasher.combine(attachment)
        case .file(let attachment):
            hasher.combine("file")
            hasher.combine(attachment)
        case .video(let attachment):
            hasher.combine("video")
            hasher.combine(attachment)
        case .link(let attachment):
            hasher.combine("link")
            hasher.combine(attachment)
        case .location(let attachment):
            hasher.combine("location")
            hasher.combine(attachment)
        case .notsupported:
            hasher.combine("notsupported")
        }
    }

    public static func == (lhs: LocalChatMessageAttachment, rhs: LocalChatMessageAttachment) -> Bool {
        switch (lhs, rhs) {
        case (.image(let lhsAttachment), .image(let rhsAttachment)):
            return lhsAttachment == rhsAttachment
        case (.file(let lhsAttachment), .file(let rhsAttachment)):
            return lhsAttachment == rhsAttachment
        case (.video(let lhsAttachment), .video(let rhsAttachment)):
            return lhsAttachment == rhsAttachment
        case (.link(let lhsAttachment), .link(let rhsAttachment)):
            return lhsAttachment == rhsAttachment
        case (.location(let lhsAttachment), .location(let rhsAttachment)):
            return lhsAttachment == rhsAttachment
        case (.notsupported, .notsupported):
            return true
        default:
            return false
        }
    }
}

extension LocalChatMessageAttachment {

    func mediaAttachment(with loader: ImageLoader, cdn: ImageCDNhandler, videoPreviewLoader: PreviewVideoLoader) -> MediaAttachment? {
        switch self {
        case .image(let imageAttachment):

            return MediaAttachment(
                imageLoader: loader,
                imageCDN: cdn,
                videoPreviewLoader: videoPreviewLoader,
                url: imageAttachment.imageUrl,
                type: .photo,
                uploadingState: imageAttachment.uploadingState
            )
        case .video(let videoAttachment):
            return MediaAttachment(
                imageLoader: loader,
                imageCDN: cdn,
                videoPreviewLoader: videoPreviewLoader,
                url: videoAttachment.url,
                type: .video,
                uploadingState: videoAttachment.uploadingState
            )
        default:
            return nil
        }
    }
}
