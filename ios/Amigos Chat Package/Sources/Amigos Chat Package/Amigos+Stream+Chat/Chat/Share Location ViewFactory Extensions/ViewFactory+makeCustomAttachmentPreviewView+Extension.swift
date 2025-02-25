//
//  ViewFactory+Custom.swift
//  App
//
//  Created by Jarret Hoving on 26/11/2024.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

extension CustomUIFactory {

    public typealias CustomAttachmentPreviewViewType = ShareLocationPreviewView

    ///  Used for displaying a custom message view component
    public func makeCustomAttachmentPreviewView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> CustomAttachmentPreviewViewType {
        ShareLocationPreviewBuilder(username: currentUsername).makeCustomAttachmentPreviewView(addedCustomAttachments: addedCustomAttachments, onCustomAttachmentTap: onCustomAttachmentTap)
    }
}
