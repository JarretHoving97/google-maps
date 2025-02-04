//
//  ImageAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

public struct ImageAttachment: Equatable, Hashable {

    let imageUrl: URL
    let uploadingState: UploadingState?

    public init(imageUrl: URL, uploadingState: UploadingState?) {
        self.imageUrl = imageUrl
        self.uploadingState = uploadingState
    }
}
