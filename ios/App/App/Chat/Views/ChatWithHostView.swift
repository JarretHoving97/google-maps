//
//  ChatWithHostView.swift
//  App
//
//  Created by Jarret on 17/12/2024.
//

import SwiftUI

class ChatWithHostViewModel {

    var title: String {
        // TODO: when merging Share Location feature use the modular approach
        tr("channel.start.message.with.host")
    }
}

struct ChatWithHostView: View {

    let viewModel = ChatWithHostViewModel()

    var onChatWithHostTapped: (() -> Void)

    var body: some View {
        HStack {
            Button(action: onChatWithHostTapped) {
                Text(viewModel.title)
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
