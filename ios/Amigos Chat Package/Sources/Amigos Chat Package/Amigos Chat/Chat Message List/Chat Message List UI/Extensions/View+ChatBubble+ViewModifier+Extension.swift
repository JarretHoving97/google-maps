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
        messagePosition: MessagePosition,
        forceLeftToRight: Bool,
        contentInsets: EdgeInsets
    ) -> some View {
        modifier(
            MessageBubbleViewModifier(
                contentInsets: contentInsets,
                isSentByCurrentUser: isSentByCurrentUser,
                shape: messagePosition.getShape(isSentByCurrentUser: isSentByCurrentUser)
            )
        )
    }
}
