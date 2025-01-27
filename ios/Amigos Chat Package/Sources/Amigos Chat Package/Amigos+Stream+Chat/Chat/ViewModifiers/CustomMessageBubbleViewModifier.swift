import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// Modifier that enables message bubble container.
public struct CustomMessageBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    public var message: ChatMessage
    public var isFirst: Bool
    public var injectedBackgroundColor: UIColor?
    public var cornerRadius: CGFloat = 18
    public var forceLeftToRight = false
    public var topPadding: CGFloat = 0
    public var bottomPadding: CGFloat = 0

    public init(
        message: ChatMessage,
        isFirst: Bool,
        injectedBackgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 18,
        forceLeftToRight: Bool = false,
        topPadding: CGFloat = 0,
        bottomPadding: CGFloat = 0
    ) {
        self.message = message
        self.isFirst = isFirst
        self.injectedBackgroundColor = injectedBackgroundColor
        self.cornerRadius = cornerRadius
        if utils.messageListConfig.messageListAlignment == .leftAligned {
            self.forceLeftToRight = true
        } else {
            self.forceLeftToRight = forceLeftToRight
        }
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
    }

    public func body(content: Content) -> some View {
        content
            .modifier(
                CustomBubbleModifier(
                    corners: message.bubbleCorners(
                        isFirst: isFirst,
                        forceLeftToRight: forceLeftToRight
                    ),
                    backgroundColors: message.bubbleBackground(
                        colors: colors,
                        injectedBackgroundColor: injectedBackgroundColor
                    ),
                    cornerRadius: cornerRadius
                )
            )
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: 8, x: 0, y: 2)
    }
}

/// Modifier that enables bubble container.
public struct CustomBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors

    var corners: UIRectCorner
    var backgroundColors: [Color]
    var cornerRadius: CGFloat

    public init(corners: UIRectCorner, backgroundColors: [Color], cornerRadius: CGFloat = 18) {
        self.corners = corners
        self.backgroundColors = backgroundColors
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(background)
            .overlay(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius, corners: corners
                )
                .stroke(lineWidth: 0)
            )
            .clipShape(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius,
                    corners: corners
                )
            )
    }

    @ViewBuilder
    private var background: some View {
        if backgroundColors.count == 1 {
            backgroundColors[0]
        } else if backgroundColors.count > 1 {
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.clear
        }
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

extension View {
    /// Applies the message bubble modifier to a view.
    /// - Parameters:
    ///  - message: the chat message.
    ///  - isFirst: whether it's the first message in a group of messages.
    ///  - backgroundColor: optional injected background color.
    public func messageBubble(
        for message: ChatMessage,
        isFirst: Bool,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 18,
        forceLeftToRight: Bool = false
    ) -> some View {
        modifier(
            CustomMessageBubbleModifier(
                message: message,
                isFirst: isFirst,
                injectedBackgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                forceLeftToRight: forceLeftToRight
            )
        )
    }

    /// Applies bubble modifier to a view.
    /// - Parameters:
    ///  - background: the bubble's background.
    ///  - corners: which corners to be rounded.
    ///  - borderColor: optional border color.
    public func bubble(
        with background: Color,
        corners: UIRectCorner,
        borderColor: Color? = nil
    ) -> some View {
        modifier(
            CustomBubbleModifier(
                corners: corners,
                backgroundColors: [background]
            )
        )
    }
}
