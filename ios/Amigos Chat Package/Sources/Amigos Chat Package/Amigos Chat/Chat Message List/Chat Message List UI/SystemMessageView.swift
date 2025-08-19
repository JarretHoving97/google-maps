//
//  SystemMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import SwiftUI

public struct SystemMessageView: View {

    let viewModel: MessageViewModel
    let message: Message

    public init(message: Message) {
        self.viewModel = MessageViewModel(message: message)
        self.message = message
    }

    public var body: some View {
        if let type = viewModel.layoutMessageType, case .anonymous = type {
            AnonymousSystemMessageView(message: message)
        } else {
            DefaultSystemMessageView(message: message)
        }
    }
}
