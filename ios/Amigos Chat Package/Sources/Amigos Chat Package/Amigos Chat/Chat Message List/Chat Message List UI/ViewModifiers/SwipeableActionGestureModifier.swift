//
//  SipeableActionsGestureModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/02/2025.
//
//  Taken from https://github.com/GetStream/stream-chat-swiftui/blob/606311b04c8c329091026f9c8e72d173e4cbd2d0/Sources/StreamChatSwiftUI/ChatChannel/MessageList/MessageContainerView.swift#L140-L175
//  And turned it into a ViewModifier
//

import SwiftUI

struct SwipeableActionGestureModifier: ViewModifier {

    var onSwipeCompleted: (() -> Void)

    @State private var offsetX: CGFloat = 0
    @GestureState private var offset: CGSize = .zero

    private let treshold: CGFloat = 100
    private let minimumSwipeGestureDisabledDistance: CGFloat = 0
    private let minimumSwipeDistance: CGFloat = 40

    init(onSwipeCompleted: @escaping (() -> Void)) {
        self.onSwipeCompleted = onSwipeCompleted
    }

    func body(content: Content) -> some View {
        content
            .offset(x: min(self.offsetX, treshold))
            .simultaneousGesture(
                DragGesture(
                    minimumDistance: minimumSwipeGestureDisabledDistance,
                    coordinateSpace: .local
                )
                .updating($offset) { (value, gestureState, _) in
                    // Using updating since onEnded is not called if the gesture is canceled.
                    let diff = CGSize(
                        width: value.location.x - value.startLocation.x,
                        height: value.location.y - value.startLocation.y
                    )

                    if diff == .zero {
                        gestureState = .zero
                    } else {
                        gestureState = value.translation
                    }
                }
            )
            .onChange(of: offset, perform: { _ in

                if offset == .zero {
                    // gesture ended or cancelled
                    setOffsetX(value: 0)
                } else {
                    dragChanged(to: offset.width)
                }
            })
    }

    private func setOffsetX(value: CGFloat) {
        withAnimation(.interpolatingSpring(stiffness: 170, damping: 20)) {
            self.offsetX = value
        }
    }

    private func dragChanged(to value: CGFloat) {
        let horizontalTranslation = value

        if horizontalTranslation < 0 {
            // prevent swiping to right.
            return
        }

        if horizontalTranslation >= minimumSwipeDistance {
            offsetX = horizontalTranslation
        } else {
            offsetX = 0
        }

        if offsetX > treshold {
            withAnimation {
                onSwipeCompleted()
            }
        }
    }

    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
