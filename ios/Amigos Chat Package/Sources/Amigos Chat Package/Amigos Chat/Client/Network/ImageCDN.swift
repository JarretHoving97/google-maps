//
//  ImageCDN.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import Foundation

public class MockImageCDN: ImageCDNhandler {

    public init() {}

    public func cachingKey(forImage url: URL) -> String {
        ""
    }

    public func urlRequest(forImage url: URL) -> URLRequest {
        URLRequest(url: url)
    }

    public func thumbnailURL(originalURL: URL, preferredSize: CGSize) -> URL {
        originalURL
    }

    func cdnUrl(for url: URL) -> URL {
        url
    }
}
