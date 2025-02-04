//
//  StreamChat+.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import StreamChat
import Foundation

extension AnyChatMessageAttachment: ChatMessageAttachmentProtocol {

    public var localType: LocalChatMessageAttachment {

        switch self.type {

        case .file:

            guard let codable = payload.decoded(to: CodableFileAttachment.self) else {
                return .notsupported
            }

            return .file(codable.toLocal())

        case .image:

            guard var imageAttachment = payload.decoded(to: CodableImageAttachment.self) else {
                return .notsupported
            }

            /// set uploading state
            imageAttachment.uploadingState = self.uploadingState?.toLocalType()

            return .image(imageAttachment.toLocal())

        case .video:

            guard var videoAttachment = payload.decoded(to: CodableVideoAttachment.self) else {
                return .notsupported
            }

            /// set uploading state
            videoAttachment.uploadingState = self.uploadingState?.toLocalType()

            return .video(videoAttachment.toLocal())

        case .linkPreview:

            guard let codable = payload.decoded(to: CodableLinkAttachment.self) else {
                return .notsupported
            }

            return .link(codable.toLocal())

        default:
            return .notsupported
        }
    }
}
