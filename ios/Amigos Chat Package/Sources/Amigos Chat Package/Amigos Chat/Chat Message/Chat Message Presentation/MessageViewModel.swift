//
//  MessageViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation

public class MessageViewModel {

    public var messageText: String {
        message.text
    }

    public var quotedMessage: Message? {
        return message.quotedMessage
    }

    public var isDeleted: Bool {
        return message.isDeleted
    }

    public var isSentByCurrentUser: Bool {
        return message.isSentByCurrentUser
    }

    public var imageAttachments: [ImageAttachment] {
        return message.imageAttachments
    }

    public var videoAttachments: [VideoAttachment] {
        return message.videoAttachments
    }

    var mediaAttachments: [MediaAttachment] {
        message.attachments.compactMap { $0.mediaAttachment(with: imageLoader, cdn: imageCDN, videoPreviewLoader: videoPreviewLoader) }
    }

    let isFirst: Bool

    let forceLeftToRight: Bool

    let imageLoader: ImageLoader

    let imageCDN: ImageCDNhandler

    let videoPreviewLoader: PreviewVideoLoader

    public private(set) var attachmentType: AttachmentType = .empty

    private let messageResolver: AmigosMessageTypeResolving

    private let message: Message

    /// used when we want other than the default `messageResolver` behaviour
    public init(
        message: Message,
        messageResolver: AmigosMessageTypeResolving,
        imageLoader: ImageLoader = DefaultImageLoader(),
        imageCDN: ImageCDNhandler = MockImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader(),
        isFirst: Bool = true,
        forceLeftToRight: Bool = false
    ) {
        self.message = message
        self.messageResolver = messageResolver
        self.imageLoader = imageLoader
        self.imageCDN = imageCDN
        self.videoPreviewLoader = videoPreviewLoader
        self.isFirst = isFirst
        self.forceLeftToRight = forceLeftToRight
    }

    public func resolveMessageType() {
        guard !messageResolver.isDeleted() else {
            attachmentType = .deleted
            return
        }

        if !message.attachments.isEmpty {
            resolveMediaTypes()
        }
    }

    private func resolveMediaTypes() {

        /// Remove all unsupported attachments
        let filteredAttachments = UnsupportedAttachmenstFilter.filter(message.attachments)

        /// show single attachment
        guard filteredAttachments.count > 1 else {

            if messageResolver.hasImageAttachment() {

                attachmentType = .image

            } else if messageResolver.hasVideoAttachment() {

                attachmentType = .video
            }

            return
        }

        /// show multiple attachments stack
        attachmentType = .multimedia
    }
}

public extension MessageViewModel {

    convenience init(
        message: Message,
        imageLoader: ImageLoader = DefaultImageLoader(),
        imageCDN: ImageCDNhandler = MockImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader(),
        isFirst: Bool = true,
        forceLeftToRight: Bool = false
    ) {
        let resolver = MessageTypeResolver(message: message)

        self.init(
            message: message,
            messageResolver: resolver,
            imageLoader: imageLoader,
            imageCDN: imageCDN,
            videoPreviewLoader: videoPreviewLoader,
            isFirst: isFirst,
            forceLeftToRight: forceLeftToRight
        )
    }
}
