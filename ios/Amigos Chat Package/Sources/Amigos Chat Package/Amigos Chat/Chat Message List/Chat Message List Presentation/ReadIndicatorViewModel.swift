//
//  ReadIndicatorViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/03/2025.
//

import SwiftUI
import StreamChatSwiftUI

class ReadIndicatorViewModel: ObservableObject {

    @Injected(\.superStatus) var superStatus

    private var isRead: Bool
    private var isReadByAll: Bool
    private var localState: Message.LocalState?

    var tintColor: Color? {
        return Color(.purple)
    }

    var hideReadStatus: Bool {
        // Do not hide while the message is pending send
        if localState == .pendingSend { return false }
        return superStatus.superEntitlementStatus != .active
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
        localState: Message.LocalState? = nil
    ) {
        self.isRead = isRead
        self.isReadByAll = isReadByAll
        self.localState = localState
    }
}
