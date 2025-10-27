//
//  QuotedMessageViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2025.
//

import SwiftUI

class QuotedMessageViewModel {

    public var messageText: String {
        return isDeleted ? tr("message.deleted-message-placeholder") : message.text
    }

    private var isDeleted: Bool {
        return message.isDeleted
    }

    public var author: String {
        message.user.name
    }

    public var locationAttachment: LocationAttachment? {
        return message.location
    }

    public var pollAttachment: LocalPoll? {
        return message.poll
    }

    public var hasUnsupportedAttachment: Bool {
        return message.attachments.contains { $0 == .notsupported }
    }

    let imageLoader: ImageLoader

    let imageCDN: ImageCDNhandler

    let videoPreviewLoader: PreviewVideoLoader

    public var isSentByCurrentUser: Bool

    private let message: Message

    init(
        message: Message,
        isSentByCurrentUser: Bool,
        imageLoader: ImageLoader = DefaultImageLoader(),
        imageCDN: ImageCDNhandler = MockImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader()
    ) {
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
        self.videoPreviewLoader = videoPreviewLoader
        self.message = message
        self.isSentByCurrentUser = isSentByCurrentUser
    }

    var mediaAttachments: [MediaAttachment] {
        message.attachments.compactMap { $0.mediaAttachment(with: imageLoader, cdn: imageCDN, videoPreviewLoader: videoPreviewLoader) }
    }

}
