//
//  BorderedMessageBubbleModifier+View+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2026.
//

import SwiftUI

extension View {

    func withBorderedMessageBubble(
        contentEgeInstes: EdgeInsets = .defaultMessageEdgeInsets,
        shape: BubbleShape = BubbleShape(cornerRadius: 16),
        tint: Color = Color(.purple),
        lineWidth: CGFloat = 1,
    ) -> some View {
        modifier(
            BorderedMessageBubbleModifier(
                contentEgeInstes: contentEgeInstes,
                shape: shape,
                tint: tint
            )
        )
    }
}

private struct BorderedMessageBubbleModifier: ViewModifier {
    let contentEgeInstes: EdgeInsets
    let shape: BubbleShape
    let tint: Color
    let lineWidth: CGFloat

    init(
        contentEgeInstes: EdgeInsets,
        shape: BubbleShape,
        tint: Color = Color(.purple),
        lineWidth: CGFloat = 2,
    ) {
        self.contentEgeInstes = contentEgeInstes
        self.shape = shape
        self.tint = tint
        self.lineWidth = lineWidth
    }

    func body(content: Content) -> some View {
        content
            .padding(contentEgeInstes)
            .clipShape(shape)
            .overlay(content: {
                shape.stroke(tint, lineWidth: lineWidth)
            })
            .foregroundStyle(tint)
    }
}
