//
//  MessageActionButton.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/09/2025.
//

import Foundation

struct MessageActionButton {

    private let path: String

    private let isSentByCurrentUser: Bool

    private let messageType: MessageType

    var buttonTheme: AmiButtonTheme {
        if messageType == .regular && isSentByCurrentUser {
            return .white
        } else {
            return .purple
        }
    }

    var route: ChannelRoute {
        .path(path)
    }

    var title: String {
        if path.hasPrefix("/upsert-activity") {
            if path.lowercased().contains("clonedActivityId".lowercased()) {
                return Localized.ChatChannel.repeatActivityActionLabel
            }

            return Localized.ChatChannel.createActivityActionLabel
        } else if path.hasPrefix("/activity-immersive") {
            return Localized.ChatChannel.viewActivityActionLabel
        } else {
            return Localized.ChatChannel.viewActionLabel
        }
    }

    init(path: String, isSentByCurrentUser: Bool, messageType: MessageType) {
        self.path = path
        self.isSentByCurrentUser = isSentByCurrentUser
        self.messageType = messageType
    }
}
