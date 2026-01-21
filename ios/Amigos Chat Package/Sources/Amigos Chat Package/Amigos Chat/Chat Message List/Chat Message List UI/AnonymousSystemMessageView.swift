//
//  AnonymousSystemMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import SwiftUI

struct AnonymousSystemMessageView: View {

    let message: Message

    let router: Router?

    public init(router: Router? = nil, message: Message) {
        self.message = message
        self.router = router
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(tr(message.text))
                    .font(.caption1)
                    .foregroundStyle(Color(.darkText))

                messageButtonView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
        .modifier(ShadowModifier())
        .padding(.all, 4)
    }

    private var messageButtonView: some View {
        Group {
            if let viewData = MessageActionResolver.resolve(from: message) {
                MessageActionButtonView(router: router, viewModel: viewData)
            }
        }
    }
}
