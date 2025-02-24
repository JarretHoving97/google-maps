//
//  CheckboxView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/02/2025.
//

import SwiftUI

struct CheckboxView: View {

    let checked: Bool

    init(selected: Bool) {
        self.checked = selected
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.6))
            Circle()
                .stroke(Color(.lightGray), lineWidth: 2)

            if checked {
                Circle()
                    .fill(.white)
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundStyle(Color(.purple))
            }
        }
        .frame(width: 26, height: 26, alignment: .center)
    }
}

#Preview {
    CheckboxView(selected: true)
}
