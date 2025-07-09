//
//  ReadIndicatorViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/03/2025.
//

import SwiftUI

class ReadIndicatorViewModel: ObservableObject {

    private var isRead: Bool
    private var isReadByAll: Bool
    private var localState: Message.LocalState?

    var tintColor: Color? {
        if isReadByAll || isRead {
            return Color(.purple)
        }

        return Color(.purple)
    }

    var icon: UIImage? {
        if localState == .pendingSend {
            return UIImage(named: "message_receipt_sending", in: .module, with: nil)
        } else if isReadByAll || isRead {

            return UIImage(named: "message_receipt_read", in: .module, with: nil)?
                .withRenderingMode(.alwaysTemplate)
        } else {
            return UIImage(named: "message_receipt_sent", in: .module, with: nil)
        }
    }

    init(
        isRead: Bool,
        isReadByAll: Bool,
        localState: Message.LocalState? = nil
    ) {
        self.isRead = isRead
        self.isReadByAll = isReadByAll
        self.localState = localState
    }
}
