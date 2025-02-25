//
//  ShareLocationViewPreviewViewModel.swift
//  App
//
//  Created by Jarret Hoving on 26/11/2024.
//

import SwiftUI
import StreamChatSwiftUI

class ShareLocationViewPreviewViewModel: ObservableObject {

    var location: LocationAttachmentPayload? {
        addedCustomAttachments.first?.content as? LocationAttachmentPayload
    }

    var shareUserLocationTitle: String {
        Localized.ShareLocation.usersLocationPreviewLabel(author: username)
    }

    private let username: String

    private var addedCustomAttachments: [CustomAttachment]

    init(username: String, addedCustomAttachments: [CustomAttachment]) {
        self.username = username
        self.addedCustomAttachments = addedCustomAttachments
    }
}
