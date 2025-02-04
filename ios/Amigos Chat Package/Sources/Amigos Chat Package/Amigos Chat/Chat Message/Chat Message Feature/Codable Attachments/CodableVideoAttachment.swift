//
//  CodableVideoAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation

struct CodableVideoAttachment: Decodable {

    public var videoURL: URL

    var uploadingState: UploadingState?

    init(videoURL: URL) {
        self.videoURL = videoURL
    }

    enum CodingKeys: String, CodingKey {
        case image
        case imageURL = "image_url"
        case assetURL = "asset_url"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let videoURL = try
            container.decodeIfPresent(URL.self, forKey: .image) ??
            container.decodeIfPresent(URL.self, forKey: .imageURL) ??
            container.decode(URL.self, forKey: .assetURL)

        self.init(videoURL: videoURL)
    }
}

extension CodableVideoAttachment {

    func toLocal() -> VideoAttachment {
        return VideoAttachment(
            url: videoURL,
            uploadingState: uploadingState
        )
    }
}
