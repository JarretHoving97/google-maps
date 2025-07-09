//
//  UnsupportedAttachmentsFilter.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Foundation

enum UnsupportedAttachmenstFilter {

    static func filter(_ attachments: [LocalChatMessageAttachment]) -> [LocalChatMessageAttachment] {
        return attachments.filter { attachment in
            switch attachment {
            case .file:
                return false

            default:
                return true
            }
        }
    }
}
