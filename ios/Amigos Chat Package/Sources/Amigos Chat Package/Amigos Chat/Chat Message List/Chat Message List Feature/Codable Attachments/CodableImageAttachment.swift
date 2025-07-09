//
//  CodableImageAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation

struct CodableImageAttachment: Decodable {

    public var imageURL: URL

    var uploadingState: UploadingState?

    enum CodingKeys: String, CodingKey {
        case image
        case imageURL = "image_url"
        case assetURL = "asset_url"
    }

    init(imageURL: URL) {
        self.imageURL = imageURL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let imageURL = try
            container.decodeIfPresent(URL.self, forKey: .image) ??
            container.decodeIfPresent(URL.self, forKey: .imageURL) ??
            container.decode(URL.self, forKey: .assetURL)

        self.init(imageURL: imageURL)
    }
}

extension CodableImageAttachment {

    func toLocal() -> ImageAttachment {
        return ImageAttachment(
            imageUrl: imageURL,
            uploadingState: uploadingState
        )
    }
}

/// A type represeting the downloading state for attachments.
public struct DownloadingState: Hashable {
    /// The local file URL of the downloaded attachment.
    ///
    /// - Note: The local file URL is available when the state is `.downloaded`.
    public let localFileURL: URL?

    /// The local download state of the attachment.
    public let state: LocalDownloadState

}

/// A type representing the uploading state for attachments that require prior uploading.
public struct UploadingState: Hashable {
    /// The local file URL that is being uploaded.
    public let localFileURL: URL

    /// The uploading state.
    public let state: LocalState

}

/// A local download state of the attachment.
public enum LocalDownloadState: Hashable {
    /// The attachment is being downloaded.
    case downloading(progress: Double)
    /// The attachment download failed.
    case downloadingFailed
    /// The attachment has been downloaded.
    case downloaded
}

/// A local state of the attachment. Applies only for attachments linked to the new messages sent from current device.
public enum LocalState: Hashable {
    /// The current state is unknown
    case unknown
    /// The attachment is waiting to be uploaded.
    case pendingUpload
    /// The attachment is currently being uploaded. The progress in [0, 1] range.
    case uploading(progress: Double)
    /// Uploading of the message failed. The system will not trying to upload this attachment anymore.
    case uploadingFailed
    /// The attachment is successfully uploaded.
    case uploaded
}
