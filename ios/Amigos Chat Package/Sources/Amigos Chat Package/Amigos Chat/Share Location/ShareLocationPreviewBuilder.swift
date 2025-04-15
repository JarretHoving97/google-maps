//
//  Untitled.swift
//  App
//
//  Created by Jarret Hoving on 26/11/2024.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

class ShareLocationPreviewBuilder {

    typealias CustomAttachmentPreviewViewType = ShareLocationPreviewView

    var username: String

    init(username: String) {
        self.username = username
    }

    func makeCustomAttachmentPreviewView(
            addedCustomAttachments: [CustomAttachment],
            onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> CustomAttachmentPreviewViewType {
        ShareLocationPreviewView(
            username: username,
            addedCustomAttachments: addedCustomAttachments,
            onCustomAttachmentTap: onCustomAttachmentTap
        )
    }
}
