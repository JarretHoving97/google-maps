//
//  ReactionBubbleViewModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import SwiftUI

/// Modifier that enables message bubble container.
public struct ReactionsBubbleModifier: ViewModifier {

    private let cornerRadius: CGFloat = 18
    let color: UIColor

    public func body(content: Content) -> some View {
        content
            .background(Color(uiColor: color))
            .clipShape(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius,
                    corners: corners
                )
            )
    }

    private var corners: UIRectCorner {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }
}

extension View {
    public func reactionsBubble(background: UIColor? = nil) -> some View {
        modifier(ReactionsBubbleModifier(color: background ?? .clear))
    }
}
