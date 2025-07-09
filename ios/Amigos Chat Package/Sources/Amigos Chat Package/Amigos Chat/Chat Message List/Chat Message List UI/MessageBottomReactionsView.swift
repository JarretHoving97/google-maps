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
        HStack(spacing: 4) {
            ForEach(viewModel.reactions) { reaction in
                HStack(spacing: 0) {
                    Text(reaction.icon)
                        .font(.system(size: 12))
                        .minimumScaleFactor(0.5)

                    if reaction.count > 1 {
                        Text(reaction.count.description)
                            .font(Font.custom(size: 10, weight: ThemeFontWeight.medium))
                            .foregroundStyle(.black)
                            .padding(.trailing, 2)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
        .reactionsBubble(background: reactionsBgColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var borderColor: Color {
        Color(hex: "#DBDDE1")
    }

    private var reactionsBgColor: UIColor {
        UIColor(hexString: "#F2F2F2", alpha: 1)!
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
