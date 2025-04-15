//
//  AttachmentDownloader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 17/02/2025.
//

import Foundation

enum AttachmentDownloader {

    enum Error: Swift.Error {
        case convertingToDataFailed
        case itemProviderFailed
    }

    static func downloadShareableActivity(from attachment: MediaAttachment) async throws -> URL {
        switch attachment.type {
        case .photo:
            try await downloadPhoto(from: attachment.url, imageLoader: attachment.imageLoader, imageCDN: attachment.imageCDN)
        case .video:
            try await downloadVideo(from: attachment.url)
        }
    }

    private static func downloadPhoto(from url: URL, imageLoader: ImageLoader, imageCDN: ImageCDNhandler) async throws -> URL {
        let image = try await imageLoader.loadImageAsync(
            url: url,
            imageCDN: imageCDN,
            resize: false,
            preferredSize: nil
        )

        guard let data = image.jpegData(compressionQuality: 1.0) else {
            throw Error.convertingToDataFailed
        }

        let name = "PHOTO_\(UUID().uuidString).jpeg"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(name)

        try data.write(to: tempURL)

        guard let itemProvider = NSItemProvider(contentsOf: tempURL) else {
            throw Error.itemProviderFailed
        }

        return tempURL
    }

    private static func downloadVideo(from url: URL) async throws -> URL {
        let request = URLRequest(url: url)

        let (localURL, response) = try await URLSession.shared.download(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let name = "VIDEO_\(UUID().uuidString).mp4"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(name)

        try FileManager.default.moveItem(at: localURL, to: tempURL)

        guard let itemProvider = NSItemProvider(contentsOf: tempURL) else {
            throw Error.itemProviderFailed
        }

        return tempURL
    }
}
