//
//  MimeTypeSafety.swift
//  App
//
//  Created by Jarret on 23/05/2025.
//

import Foundation

struct MimeTypeSafety {

    static private let imageMimeTypes: Set<String> = [
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/heic",
        "video/mp4",
        "video/quicktime",
        "video/x-m4v"
    ]

    static func isSafeMimeType(mimeType: String) -> Bool {
        return imageMimeTypes.contains(mimeType)
    }
}
