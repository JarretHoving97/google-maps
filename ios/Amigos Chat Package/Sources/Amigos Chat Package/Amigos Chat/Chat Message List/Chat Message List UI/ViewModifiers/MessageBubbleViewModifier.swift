//
//  MessageBubbleView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import SwiftUI

struct MessageBubbleViewModifier: ViewModifier {
    let shape: BubbleShape
    let isSentByCurrentUser: Bool
    let contentInsets: EdgeInsets
    let hidden: Bool

    init(contentInsets: EdgeInsets, isSentByCurrentUser: Bool, hidden: Bool = false, shape: BubbleShape) {
        self.shape = shape
        self.contentInsets = contentInsets
        self.hidden = hidden
        self.isSentByCurrentUser = isSentByCurrentUser
    }

    private var background: some View {
        isSentByCurrentUser ? Color(.purple) : Color(.backgroundBubble)
    }

    func body(content: Content) -> some View {
        content
            .padding(contentInsets)
            .background(background.opacity(hidden ? 0 : 1))
            .clipShape(shape)
    }
}

extension MessageBubbleViewModifier {
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

public enum MessagePosition {

    case top
    case middle
    case bottom
    case alone

    func getShape(isSentByCurrentUser: Bool) -> BubbleShape {
        switch self {
        case .top:
            if isSentByCurrentUser {
                BubbleShape(topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 3)
            } else {
                BubbleShape(topLeading: 16, topTrailing: 16, bottomLeading: 3, bottomTrailing: 16)
            }

        case .middle:
            if isSentByCurrentUser {
                BubbleShape(topLeft: 16, topRight: 3, bottomLeft: 16, bottomRight: 3)
            } else {
                BubbleShape(topLeft: 3, topRight: 16, bottomLeft: 3, bottomRight: 16)
            }

        case .bottom:
            if isSentByCurrentUser {
                BubbleShape(topLeft: 16, topRight: 3, bottomLeft: 16, bottomRight: 16)
            } else {
                BubbleShape(topLeft: 3, topRight: 16, bottomLeft: 16, bottomRight: 16)
            }

        case .alone:
            BubbleShape(cornerRadius: 16)
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
