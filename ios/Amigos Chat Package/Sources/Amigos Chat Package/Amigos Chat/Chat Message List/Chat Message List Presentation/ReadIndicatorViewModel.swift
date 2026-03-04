//
//  ReadIndicatorViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/03/2025.
//

import SwiftUI
import UIKit.UIImage

/// exception: needed for `@Injected` which is taken by stream
import StreamChatSwiftUI

@MainActor
class ReadIndicatorViewModel: ObservableObject {

    @Injected(\.superStatus) var superStatus

    private let readsForMessageHandler: ReadsForMessageHandler

    private let message: Message?

    init(readsForMessageHandler: ReadsForMessageHandler, message: Message?) {
        self.readsForMessageHandler = readsForMessageHandler
        self.message = message
    }

    var hideReadStatus: Bool {
        // Do not hide while the message is pending
        if message?.localState == .pendingSend { return false }
        return superStatus.superEntitlementStatus != .active
    }

    var readUsers: [LocalUser] {
        return readsForMessageHandler.readUsers(message: message)
    }

    var tintColor: Color? {
        return Color(.purple)
    }

    var image: UIImage {
        shouldShowReads ? .messageReceiptRead : (isMessageSending ? .messageReceiptSending : .messageReceiptSent)!
    }

    private var shouldShowReads: Bool {
        !readUsers.isEmpty && !isMessageSending
    }

    private var isMessageSending: Bool {
        message?.localState == .sending || message?.localState == .pendingSend || message?.localState == .syncing
    }
}

private extension UIImage {

    static var messageReceiptRead: UIImage {
        UIImage(named: "message_receipt_read", in: .module, with: nil)!
    }

    static var messageReceiptSending: UIImage {
        UIImage(named: "message_receipt_sending", in: .module, with: nil)!
    }

    static var messageReceiptSent: UIImage {
        UIImage(named: "message_receipt_sent", in: .module, with: nil)!
    }
}

extension ReadIndicatorViewModel {
    @MainActor
    static var empty = ReadIndicatorViewModel(
        readsForMessageHandler: PlaceholderMessageReadHelper(),
        message: nil
    )
}
