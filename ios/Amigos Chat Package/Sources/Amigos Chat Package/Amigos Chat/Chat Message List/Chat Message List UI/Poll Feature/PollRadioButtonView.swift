//
//  PollRadioButtonView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 03/11/2025.
//

import SwiftUI

struct PollRadioButtonView: View {

    let isSelected: Bool
    let isSentByCurrentUser: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .foregroundStyle(tintColor)
        }
        .buttonStyle(.plain)
    }

    private var symbolName: String {
        isSelected ? "checkmark.circle.fill" : "circle"
    }

    private var tintColor: Color {
        if isSentByCurrentUser {
            return isSelected
                ? Color(.white)
                : Color(.white).opacity(0.2)
        } else {
            return isSelected
                ? Color(.purple)
                : Color(.greyDark).opacity(0.1)
        }
    }
}
