//
//  MessageMapper.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import Foundation

/// Map third party messageto our own components
/// so models won't be tight coupled to our UI
public class MessageMapper {

    private let attachmentsMapper = LocalChatMessageAttachmentMapper()
    private let quotedMessageMapper = QuotedMessageMapper()

    public init() {}

    public func map(_ remoteMessage: ChatMessageProtocol) -> Message {
        Message(
            id: remoteMessage.id,
            user: remoteMessage.user.toLocal(),
            isSentByCurrentUser: remoteMessage.isSentByCurrentUser,
            message: remoteMessage.text,
            quotedMessage: quotedMessageMapper.mapQuotedMessageFactory(
                quotedMessage: remoteMessage.localQuotedMessage,
                attachmentsMapper: attachmentsMapper
            ),
            isDeleted: remoteMessage.isDeleted,
            attachments: attachmentsMapper.mapAttachmentsFactory(remoteMessage.attachments),
            layoutKey: remoteMessage.layoutKey
        )
    }
}

struct QuotedMessageMapper {

    func mapQuotedMessageFactory(quotedMessage: ChatMessageProtocol?, attachmentsMapper: LocalChatMessageAttachmentMapper) -> (() -> Message?)? {

        if let quotedMessage = quotedMessage {

            return {
                Message(
                    id: quotedMessage.id,
                    user: quotedMessage.user.toLocal(),
                    message: quotedMessage.textContent ?? "",
                    isDeleted: quotedMessage.isDeleted,
                    attachments: attachmentsMapper.mapAttachmentsFactory(quotedMessage.attachments)
                )
            }
        }
        return nil
    }
}

struct LocalChatMessageAttachmentMapper {

    func mapAttachmentsFactory(_ remoteAttachments: [ChatMessageAttachmentProtocol]) -> [LocalChatMessageAttachment] {

        return remoteAttachments.compactMap { from(anyAttachment: $0) }
    }

    private func from(anyAttachment: ChatMessageAttachmentProtocol) -> LocalChatMessageAttachment? {

        return anyAttachment.localType
    }
}
