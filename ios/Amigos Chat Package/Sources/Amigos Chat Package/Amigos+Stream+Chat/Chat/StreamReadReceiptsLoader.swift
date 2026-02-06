//
//  StreamReadReceiptsLoader.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/01/2026.
//

import Foundation
import StreamChat

final class StreamReadReceiptsLoader: ReadReceiptsLoader {

    private let controller: ChatChannelController

    private var currentUserId: String {
        return controller.client.currentUserId ?? ""
    }

    private let messageDate: Date

    init(controller: ChatChannelController, messageDate: Date) {
        self.controller = controller
        self.messageDate = messageDate
        self.offset = controller.channel?.reads.count ?? 0

    }
    private var offset: Int
    private var hasMore: Bool = true
    private let pageSize: Int = 50

    func load(completion: @escaping ReadReceiptsResult) {

        guard hasMore else { completion(.success([])); return }
        let previousCount = offset
        controller.loadChannelReads(pagination: Pagination(pageSize: pageSize, offset: offset)) { [weak self] error in
            guard let self else { return  }

            if let error {
                completion(.failure(error))
                return
            }

            let reads = controller.channel?.reads ?? []

            self.offset = reads.count

            let newItemsCount = max(0, reads.count - previousCount)

            if newItemsCount < self.pageSize {
                self.hasMore = false
            }

            let readReceipts = ReadReceiptCellViewModelMapper.readViewData(
                from: reads,
                from: messageDate,
                currentUser: currentUserId
            )

            completion(.success(readReceipts))
        }
    }
}


