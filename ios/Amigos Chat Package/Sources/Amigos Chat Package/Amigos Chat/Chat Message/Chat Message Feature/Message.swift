//
//  Message.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

public struct LocalUser {
    let id: UUID
    let name: String
    let isModerator: Bool

    public init(id: UUID, name: String, isModerator: Bool = false) {
        self.id = id
        self.name = name
        self.isModerator = isModerator
    }
}

public struct Message {

    public let id: UUID

    public let text: String

    public let isDeleted: Bool

    public let isSentByCurrentUser: Bool

    public let user: LocalUser

    public let attachments: [LocalChatMessageAttachment]

    public let layoutKey: String?

    public var quotedMessage: Message? {
        _quotedMessage?()
    }

    private let _quotedMessage: (() -> Message?)?

    public init(
        id: UUID = UUID(),
        user: LocalUser = LocalUser(id: UUID(), name: "Jarret"),
        isSentByCurrentUser: Bool = false,
        message: String = "",
        quotedMessage: (() -> Message?)? = nil,
        isDeleted: Bool = false,
        attachments: [LocalChatMessageAttachment] = [],
        layoutKey: String? = nil

    ) {
        self.id = id
        self.isSentByCurrentUser = isSentByCurrentUser
        self.text = message
        self.isDeleted = isDeleted
        self.attachments = attachments
        self._quotedMessage = quotedMessage
        self.user = user
        self.layoutKey = layoutKey
    }
}

public extension Message {

    var imageAttachments: [ImageAttachment] {
        return attachments(payloadType: ImageAttachment.self)
    }

    var fileAttachments: [FileAttachment] {
        return attachments(payloadType: FileAttachment.self)
    }

    var videoAttachments: [VideoAttachment] {
        return attachments(payloadType: VideoAttachment.self)
    }

    var linkAttachments: [LinkAttachment] {
        return attachments(payloadType: LinkAttachment.self)
    }

}

extension Message: Equatable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Message, rhs: Message) -> Bool {
        guard lhs.id == rhs.id,
              lhs.isDeleted == rhs.isDeleted,
              lhs.text == rhs.text,
              lhs.attachments.count == rhs.attachments.count,
              lhs.quotedMessage == rhs.quotedMessage  else {
            return false
        }

        for (lhsAttachment, rhsAttachment) in zip(lhs.attachments, rhs.attachments) {
            guard lhsAttachment == rhsAttachment else {
                return false
            }
        }

        return true
    }

    func attachments<Payload: Equatable & Hashable>(payloadType: Payload.Type) -> [Payload] {
        return attachments.compactMap { attachment in
            switch attachment {
            case .image(let attachment) where payloadType == ImageAttachment.self:
                return attachment as? Payload
            case .file(let attachment) where payloadType == FileAttachment.self:
                return attachment as? Payload
            case .video(let attachment) where payloadType == VideoAttachment.self:
                return attachment as? Payload
            case .link(let attachment) where payloadType == LinkAttachment.self:
                return attachment as? Payload
            default:
                return nil
            }
        }
    }
}
