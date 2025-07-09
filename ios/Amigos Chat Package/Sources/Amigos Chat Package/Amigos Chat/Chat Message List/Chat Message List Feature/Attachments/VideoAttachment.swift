//
//  VideoAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

public struct VideoAttachment: Equatable, Hashable {

    let url: URL
    let uploadingState: UploadingState?

    public init(url: URL, uploadingState: UploadingState?) {
        self.url = url
        self.uploadingState = uploadingState
    }
}
