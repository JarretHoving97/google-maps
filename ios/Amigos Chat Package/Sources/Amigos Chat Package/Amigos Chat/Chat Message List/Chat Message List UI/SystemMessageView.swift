//
//  SystemMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import SwiftUI

public struct SystemMessageView: View {

    private let router: Router?
    let viewModel: MessageViewModel
    let message: Message

    init(router: Router?, viewModel: MessageViewModel, message: Message) {
        self.router = router
        self.viewModel = viewModel
        self.message = message
    }

    public var body: some View {
        if let type = viewModel.layoutMessageType, case .anonymous = type {
            AnonymousSystemMessageView(message: message)
        } else {
            DefaultSystemMessageView(router: router, message: message)
        }
    }
}
