//
//  IceBreakerButton.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/02/2026.
//

import SwiftUI

struct IceBreakerButton: View {

    private let action: () -> Void

    init(_ action: @escaping () -> Void = {}) {
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Circle().fill(Color(.purple)).frame(width: 40, height: 40)
                .overlay {
                    Image(.hammer)
                        .foregroundStyle(.white)
                }
        }
    }
}

#Preview {
    IceBreakerButton()
}
