//
//  LocationMessageTypeResolver.swift
//  App
//
//  Created by Jarret Hoving on 26/11/2024.
//

import StreamChat
import StreamChatSwiftUI

class LocationMessageTypeResolver: MessageTypeResolving {

    func hasCustomAttachment(message: ChatMessage) -> Bool {
        let locationAttachments = message.attachments(payloadType: LocationAttachmentPayload.self)
        return locationAttachments.count > 0
    }
}
