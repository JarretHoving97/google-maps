//
//  MessageBottomReactionsView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 07/03/2025.
//

import SwiftUI

struct MessageBottomReactionsView: View {

    var viewModel: MessageBottomReactionsViewModel

    init(viewModel: MessageBottomReactionsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(viewModel.reactions) { reaction in
                HStack(alignment: .center, spacing: 2) {
                    Text(reaction.icon)
                        .font(.custom(size: 13, weight: .regular))

                    if reaction.count > 1 {
                        Text(reaction.count.description)
                            .font(Font.custom(size: 11, weight: .medium))
                            .foregroundStyle(Color(.gray))
                            .padding(.trailing, 2)
                    }
                }
            }
        }
        .padding(4)
        .reactionsBubble(background: Color(.reactionBubbleBackground))
        .overlay(overlayView)
    }

    private var overlayView: some View {
        Group {
            if viewModel.reactions.count == 1 && viewModel.reactions[0].count == 1 {
                Circle()
                    .stroke(.white, lineWidth: 2)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white, lineWidth: 2)
            }
        }
    }
}

#Preview {
    MessageBottomReactionsView(
        viewModel: MessageBottomReactionsViewModel(
            reactions: [
                ReactionType(rawValue: "tears-of-joy"): 1,
                ReactionType(rawValue: "heart"): 2
            ]
        )
    )
}
