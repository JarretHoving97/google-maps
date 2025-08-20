//
//  ChannelHeaderButtonView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 14/01/2025.
//

import SwiftUI

struct ChannelHeaderButtonView: View {

    let title: String

    let onButtonPress: (() -> Void)

    var body: some View {
        HStack {
            Button(action: onButtonPress) {
                Text(title)
                    .font(Font.custom(size: 14, weight: .regular))
                ZStack {
                    Circle()
                        .foregroundStyle(Color(.purple))

                    Image(systemName: "plus")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .frame(width: 12, height: 12)
                }
                .frame(width: 24, height: 24)
            }
            .tint(Color(.darkText))
        }
    }
}
