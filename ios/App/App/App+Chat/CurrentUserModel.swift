//
//  CurrentUserModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 14/01/2025.
//

import Foundation

/// For read counts
class CurrentUserModel {

    struct LocalUnreadCount {
        let channels: Int
        let messages: Int
    }

    var onDidChangeUnreadCount: ((LocalUnreadCount) -> Void)

    init(onDidChangeUnreadCount: @escaping (LocalUnreadCount) -> Void) {
        self.onDidChangeUnreadCount = onDidChangeUnreadCount
    }
}
