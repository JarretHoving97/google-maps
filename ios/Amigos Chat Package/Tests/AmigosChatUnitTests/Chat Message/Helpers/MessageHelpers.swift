//
//  Untitled.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation
import Amigos_Chat_Package

func makeMessage(
    text: String = "",
    quotedMessage: (() -> Message?)? = nil,
    attachments: [LocalChatMessageAttachment] = [],
    isDeleted: Bool = false
) -> Message {
    Message(message: text, quotedMessage: quotedMessage, isDeleted: isDeleted, attachments: attachments)
}

func makeQuotedMessage(
    id: String = UUID().uuidString,
    text: String = "",
    attachments: [LocalChatMessageAttachment] = []
) -> () -> Message {
    { Message(id: id, message: text, attachments: attachments) }
}

private func makeImageURL() -> URL {
    URL(string: "https://example.com")!
}

func makeImageAttachment() -> LocalChatMessageAttachment {
    .image(ImageAttachment(imageUrl: makeImageURL(), uploadingState: nil))
}

func makeVideoAttachment() -> LocalChatMessageAttachment {
    .video(VideoAttachment(url: makeImageURL(), uploadingState: nil))
}

func makeFileAttachment() -> LocalChatMessageAttachment {
    .file(FileAttachment())
}
