//
//  CurrentUserDelegate+.swift
//  App
//
//  Created by Jarret on 10/01/2025.
//

import StreamChat

extension CurrentUserModel: CurrentChatUserControllerDelegate {

    func currentUserController(_ controller: CurrentChatUserController, didChangeCurrentUserUnreadCount unreadCount: UnreadCount) {
        onDidChangeUnreadCount(LocalUnreadCount(channels: unreadCount.channels, messages: unreadCount.messages))
    }
}
