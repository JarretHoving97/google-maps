//
//  ReadReceiptsViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/01/2026.
//

import Foundation

class ReadReceiptsViewModel: ObservableObject {

    private let receiptsLoader: any ReadReceiptsLoader

    @Published var receipts: [ReadReceiptCellViewModel]

    @Published var isLoading: Bool = false

     var isEmpty: Bool {
         return receipts.isEmpty
    }

    init(receiptsLoader: any ReadReceiptsLoader, receipts: [ReadReceiptCellViewModel]) {
        self.receiptsLoader = receiptsLoader
        self.receipts = receipts
    }

    func loadReceipts(for index: Int) {
        guard index >= receipts.count - 10 else { return }
        guard !isLoading else { return }
        self.isLoading = true

        receiptsLoader.load { [weak self] result in
            guard let self else { return }

            defer { isLoading = false }

            switch result {
            case let .success(newReceipts):
                let existing = Set(receipts.map { $0.id })
                receipts.append(contentsOf: newReceipts.filter { !existing.contains($0.id) })

            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    var navigationTitleLabel: String {
        return Localized.ChatChannel.readReceiptsNavigationTitle
    }

    var readByLabel: String {
        return Localized.ChatChannel.readReceiptsReadByHeaderLabel
    }

    var noReadReceiptsLabel: String {
        return Localized.ChatChannel.noReadReceiptsLabel
    }
}
