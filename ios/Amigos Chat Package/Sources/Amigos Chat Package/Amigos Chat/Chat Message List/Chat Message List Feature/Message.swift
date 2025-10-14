//
//  Message.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

public struct LocalUser: Equatable, Hashable, Identifiable {
    public let id: String
    let name: String
    let isModerator: Bool
    var imageUrl: URL?

    public init(id: String, name: String, imageUrl: URL? = nil, isModerator: Bool = false) {
        self.id = id
        self.name = name
        self.isModerator = isModerator
        self.imageUrl = imageUrl
    }
}

public struct Message {

    public let id: String

    public let text: String

    public let isDeleted: Bool

    public let isSentByCurrentUser: Bool

    public let user: LocalUser

    public let attachments: [LocalChatMessageAttachment]

    public let reactions: [ReactionType: Int]

    public let layoutKey: String?

    public let translationKey: TranslationKey?

    public let actionUrl: String?

    public let replyCount: Int

    public let threadParticipants: [LocalChatUser]

    public var quotedMessage: Message? {
        _quotedMessage?()
    }

    private let _quotedMessage: (() -> Message?)?

    public var localState: LocalState?

    public let type: MessageType

    public let poll: LocalPoll?

    let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        user: LocalUser = LocalUser(id: .uniqueID, name: "", imageUrl: nil),
        isSentByCurrentUser: Bool = false,
        message: String = "",
        quotedMessage: (() -> Message?)? = nil,
        reactions: [ReactionType: Int] = [:],
        isDeleted: Bool = false,
        attachments: [LocalChatMessageAttachment] = [],
        layoutKey: String? = nil,
        translationKey: TranslationKey? = nil,
        actionUrl: String? = nil,
        localState: LocalState? = nil,
        createdAt: Date = Date(),
        type: MessageType = .regular,
        poll: LocalPoll? = nil,
        replyCount: Int = 0,
        threadParticipants: [LocalChatUser] = []

    ) {
        self.id = id
        self.isSentByCurrentUser = isSentByCurrentUser
        self.text = message
        self.isDeleted = isDeleted
        self.attachments = attachments
        self.reactions = reactions
        self._quotedMessage = quotedMessage
        self.user = user
        self.layoutKey = layoutKey
        self.localState = localState
        self.createdAt = createdAt
        self.type = type
        self.translationKey = translationKey
        self.actionUrl = actionUrl
        self.poll = poll
        self.replyCount = replyCount
        self.threadParticipants = threadParticipants
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

    var location: LocationAttachment? {
        return attachments(payloadType: LocationAttachment.self).first
    }
}

extension Message: Equatable, Hashable, Identifiable {

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
            case .location(let attachment) where payloadType == LocationAttachment.self:
                return attachment as? Payload
            default:
                return nil
            }
        }
    }
}
