//
//  AnonymousSystemMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import SwiftUI

struct AnonymousSystemMessageView: View {

    let message: Message

    public init(message: Message) {
        self.message = message
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(tr(message.text))
                .font(.caption1)
                .foregroundStyle(Color(.darkText))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
        .modifier(ShadowModifier())
        .padding(.all, 4)
    }
}
