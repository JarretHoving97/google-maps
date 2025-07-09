//
//  View+ChatBubble+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//
import SwiftUI

extension View {

    func chatBubble(
        isSentByCurrentUser: Bool,
        isFirst: Bool,
        forceLeftToRight: Bool,
        contentInsets: EdgeInsets
    ) -> some View {
        modifier(MessageBubbleViewModifier(
            contentInsets: contentInsets, model: .init(
                isSentByCurrentUser: isSentByCurrentUser,
                isFirst: isFirst,
                forceLeftToRight: forceLeftToRight)
            )
        )
    }

    func chatBubble(_ model: MessageBubbleViewModifier.MessageBubbleModel, contentInsets: EdgeInsets) -> some View {
        modifier(MessageBubbleViewModifier(contentInsets: contentInsets, model: model))
    }
}
