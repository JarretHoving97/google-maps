//
//  MessageViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation

public class MessageViewModel: ObservableObject {

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

    public var locationAttachment: LocationAttachment? {
        return message.location
    }

    public var singleMediaAttachment: SingleMediaAttachmentViewModel? {
        guard let attachment = message.attachments.first, let singleMediaAttachment = attachment.toSingleMediaAttachmentType() else { return nil }

        return SingleMediaAttachmentViewModel(
            attachment: singleMediaAttachment,
            author: author,
            videoPreviewLoader: videoPreviewLoader,
            imageLoader: imageLoader,
            imageCDN: imageCDN
        )
    }

    var mediaAttachments: [MediaAttachment] {
        return _mediaAttachments
    }

    private lazy var _mediaAttachments: [MediaAttachment] = {
        return message.attachments.compactMap {
            $0.mediaAttachment(with: imageLoader, cdn: imageCDN, videoPreviewLoader: videoPreviewLoader)
        }
    }()

    var asSuperEmoji: Bool {
        messageText.containsOnlyEmoji && message.text.count <= 3 && !hasAttachment
    }

    var hasAttachment: Bool {
        return !imageAttachments.isEmpty ||
            !videoAttachments.isEmpty ||
            locationAttachment != nil ||
            !mediaAttachments.isEmpty
    }

    var author: LocalUser {
        return message.user
    }

    let isFirst: Bool

    let forceLeftToRight: Bool

    let imageLoader: ImageLoader

    let imageCDN: ImageCDNhandler

    let videoPreviewLoader: PreviewVideoLoader

    public private(set) var attachmentType: LocalAttachmentType = .empty

    private let messageResolver: AmigosMessageTypeResolving

    let message: Message

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

extension MessageViewModel {

    var bubbleHidden: Bool {
        return isDeleted || asSuperEmoji && quotedMessage == nil
    }

    var layoutMessageType: LayoutMessageType? {
        LayoutMessageType(rawValue: message.layoutKey ?? "")
    }

    var messageType: MessageType {
        return message.type
    }
}

public enum MessageType: String {
    case regular

    case system

    case deleted
}
