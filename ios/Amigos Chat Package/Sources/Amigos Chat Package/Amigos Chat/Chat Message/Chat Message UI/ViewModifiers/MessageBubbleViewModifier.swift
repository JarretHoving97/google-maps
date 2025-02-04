//
//  MessageBubbleView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

struct MessageBubbleViewModifier: ViewModifier {
    let model: MessageBubbleModel
    let cornerRadius: CGFloat = 18
    let contentInsets: EdgeInsets
    init(contentInsets: EdgeInsets, model: MessageBubbleModel) {
        self.model = model
        self.contentInsets = contentInsets
    }

    private var corners: UIRectCorner {
        bubbleCorners(
            isFirst: model.isFirst,
            forceLeftToRight: model.forceLeftToRight
        )
    }

    private var background: some View {
        model.isSentByCurrentUser ? Color(.purple) : .white
    }

    func body(content: Content) -> some View {
        content
            .padding(contentInsets)
            .background(background)
            .clipShape(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius,
                    corners: corners
                )
            )
            .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.04),
                radius: 8, x: 0, y: 2
            )
    }
}

extension MessageBubbleViewModifier {

    /// Returns the default corners that will be rounded by the message bubble modifier.
    /// - Parameters:
    ///  - isFirst: whether the message is first.
    ///  - forceLeftToRight: whether left to right should be forced.
    /// - Returns: the corners to be rounded in the message cell.
    private func bubbleCorners(isFirst: Bool, forceLeftToRight: Bool) -> UIRectCorner {
        if !isFirst {
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }

        if model.isSentByCurrentUser && !model.forceLeftToRight {
            return [.topLeft, .topRight, .bottomLeft]
        } else {
            return [.topLeft, .topRight, .bottomRight]
        }
    }

    /// Shape that allows rounding of arbitrary corners.
    public struct BubbleBackgroundShape: Shape {
        var cornerRadius: CGFloat
        var corners: UIRectCorner

        public func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )

            return Path(path.cgPath)
        }
    }
}

extension MessageBubbleViewModifier {

    public struct MessageBubbleModel {
        let isSentByCurrentUser: Bool
        let isFirst: Bool
        let forceLeftToRight: Bool

        public init(isSentByCurrentUser: Bool, isFirst: Bool, forceLeftToRight: Bool) {
            self.isFirst = isFirst
            self.forceLeftToRight = forceLeftToRight
            self.isSentByCurrentUser = isSentByCurrentUser
        }
    }
}

#Preview {
    MessageView(
        viewModel: MessageViewModel(
            message: Message(
                message: TextExamples.largeMessageText,
                quotedMessage: { Message(message: "Quoted Message") },
                isDeleted: false
            )
        )
    )
}
