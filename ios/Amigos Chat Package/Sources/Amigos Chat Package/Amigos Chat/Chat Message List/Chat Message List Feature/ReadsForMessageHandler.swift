//
//  ReadsForMessageHandler.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/02/2026.
//

import Foundation

protocol ReadsForMessageHandler {

    var currentUserId: String? { get }
    func readUsers(message: Message?) -> [LocalUser]
}

struct PlaceholderMessageReadHelper: ReadsForMessageHandler {

    var currentUserId: String?

    func readUsers(message: Message?) -> [LocalUser] {
        return []
    }
}
