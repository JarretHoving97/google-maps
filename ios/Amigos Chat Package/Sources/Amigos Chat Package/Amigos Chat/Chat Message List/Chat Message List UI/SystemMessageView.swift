//
//  SystemMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import SwiftUI

public struct SystemMessageView: View {

    private let router: Router?
    let message: Message

    var layoutType: LayoutMessageType? {
        return LayoutMessageType(rawValue: message.layoutKey ?? "")
    }

    init(router: Router?, message: Message) {
        self.router = router
        self.message = message
    }

    public var body: some View {
        if let type = layoutType, case .anonymous = type {
            AnonymousSystemMessageView(router: router, message: message)
        } else {
            DefaultSystemMessageView(router: router, message: message)
        }
    }
}
