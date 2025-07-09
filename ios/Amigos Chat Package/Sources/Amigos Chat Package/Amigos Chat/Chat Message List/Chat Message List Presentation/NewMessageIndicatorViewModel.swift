//
//  NewMessageIndicatorViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/06/2025.
//

import Foundation

class NewMessageIndicatorViewModel: ObservableObject {
    let newMessageStartId: String?
    let show: Bool
    let count: Int

    init(newMessageStartId: String?, show: Bool, count: Int) {
        self.newMessageStartId = newMessageStartId
        self.show = show
        self.count = count
    }

    var newMessageLabel: String {
        return tr("custom.newMessagesIndicator.title", count)
    }
}
