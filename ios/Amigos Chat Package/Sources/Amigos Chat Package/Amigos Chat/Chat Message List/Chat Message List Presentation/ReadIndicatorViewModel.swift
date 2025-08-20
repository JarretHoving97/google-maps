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
    private var memberCount: Int

    var tintColor: Color? {
        return Color(.purple)
    }

    var icon: UIImage? {
        if localState == .pendingSend {
            return UIImage(named: "message_receipt_sending", in: .module, with: nil)

        } else if isReadByAll {
            return UIImage(named: "message_receipt_read", in: .module, with: nil)?
                .withRenderingMode(.alwaysTemplate)
        } else if isRead {
                return UIImage(named: "message_receipt_sent", in: .module, with: nil)
        } else {
            return UIImage(named: "message_receipt_sent", in: .module, with: nil)
        }
    }

    init(
        isRead: Bool,
        isReadByAll: Bool,
        localState: Message.LocalState? = nil,
        memberCount: Int = 0
    ) {
        self.isRead = isRead
        self.isReadByAll = isReadByAll
        self.localState = localState
        self.memberCount = memberCount
    }
}
