//
//  ChatMessageProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation
import StreamChat

public protocol ChatMessageProtocol {
    var id: String { get }
    var user: Author { get }
    var isSentByCurrentUser: Bool { get }
    var text: String { get }
    var localQuotedMessage: ChatMessageProtocol? { get }
    var isDeleted: Bool { get }
    var attachments: [ChatMessageAttachmentProtocol] { get }
    var layoutKey: String? { get }
    var actionUrl: String? { get }
    var sendingState: String? { get }
    var createdAt: Date { get }
    var reactions: [String: Int] { get }
    var textContent: String? { get }
    var pinDetails: MessagePinDetails? { get }
    var messageType: String { get }
    var translationKey: TranslationKey? { get }
    var localPoll: LocalPoll? { get }
}

public protocol ChatMessageAttachmentProtocol {
    var localType: LocalChatMessageAttachment { get }
    var payload: Data { get }
}

public protocol Author {
    var userId: String { get }
    var name: String? { get }
    var imageURL: URL? { get }
    var role: any AnyRole { get }
}

extension Author {

    func toLocal() -> LocalUser {
        LocalUser(
            id: userId,
            name: name ?? "",
            imageUrl: imageURL,
            isModerator: role.rawValue == "moderator"
        )
    }
}

public protocol AnyRole: RawRepresentable, Codable, Hashable, ExpressibleByStringLiteral {
    var rawValue: String { get }

    init(rawValue: String)

    init(stringLiteral value: String)
}
