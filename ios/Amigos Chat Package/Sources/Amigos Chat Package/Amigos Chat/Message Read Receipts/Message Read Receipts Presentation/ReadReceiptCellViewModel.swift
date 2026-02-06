//
//  ReadReceiptCellViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/01/2026.
//

import Foundation

struct ReadReceiptCellViewModel: Hashable {

    private let user: LocalChatUser

    init(user: LocalChatUser) {
        self.user = user
    }

    var title: String {
        return user.name ?? ""
    }

    var avatarImageUrl: URL? {
        return user.imageUrl
    }

    var id: String {
        return user.id
    }
}
