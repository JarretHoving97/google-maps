//
//  AmiButtonRegular.swift
//  App
//
//  Created by Jarret on 03/12/2024.
//

import SwiftUI
import StreamChatSwiftUI

struct AmiButtonRegular: View {
    @Injected(\.fonts) var fonts

    let title: String
    var fluid: Bool
    var disabled: Bool
    let action: (() -> Void)?

    init(
        _ title: String,
        fluid: Bool = true,
        disabled: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.action = action
        self.fluid = fluid
        self.disabled = disabled
    }

    var background: Color {
        var color = Color("Purple")

        if disabled {
            color = color.opacity(0.3)
        }

        return color
    }

    var body: some View {
        Button { action?() } label: {
            Text(title)
                .frame(maxWidth: fluid ? .infinity : nil)
                .contentShape(Rectangle())
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .foregroundColor(.white)
                .opacity(1)
                .background(background)
                .cornerRadius(100)
                .font(fonts.subheadline)
        }
            .buttonStyle(.plain)
            .disabled(disabled)
    }
}
