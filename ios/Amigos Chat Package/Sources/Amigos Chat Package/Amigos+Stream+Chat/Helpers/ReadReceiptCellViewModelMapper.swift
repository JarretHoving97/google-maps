//
//  ReadReceiptCellViewModelMapper.swift
//  Amigos Chat Package
//
//  Created by Jarret on 30/01/2026.
//

import Foundation
import StreamChat

enum ReadReceiptCellViewModelMapper {

    static func readViewData(
        from collection: [ChatChannelRead],
        from date: Date,
        currentUser: String?
    ) -> [ReadReceiptCellViewModel] {
        collection
            .filter { $0.lastReadAt >= date}
            .filter { $0.user.id != currentUser }
            .map { ReadReceiptCellViewModel(user: LocalChatUser(from: $0.user)) }
    }
}
