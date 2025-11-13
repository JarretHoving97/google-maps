//
//  MessageGesturesModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 02/07/2025.
//

import SwiftUI

/// in iOS 18 and later, the swipeable modifier does not conflict with the scroll view.
struct MessageGesturesModifier: ViewModifier {
    let disabled: Bool
    let onSwipe: () -> Void
    let onLongPress: () -> Void

    func body(content: Content) -> some View {
        Group {
            if disabled {
                // When disabled, prevent any interaction from reaching the content or overlay gestures.
                content
                    .allowsHitTesting(false)
            } else {
                if #available(iOS 18, *) {
                    content
                        .swipeable(onSwipeCompleted: onSwipe)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.2, maximumDistance: 20)
                                .onEnded { _ in onLongPress() }
                        )
                } else {
                    // On older iOS versions, we attach a UIKit long-press recognizer via overlay.
                    content
                        .overlay(LongTapGesureView(callback: onLongPress))
                }
            }
        }
    }
}

/// A work around for long press gesture on iOS versions before 18.0.
/// So it does not conflict with the scrollview.
fileprivate struct LongTapGesureView: UIViewRepresentable {
    let callback: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let gesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.action))
        gesture.delegate = context.coordinator
        gesture.cancelsTouchesInView = false
        gesture.minimumPressDuration = 0.2
        gesture.allowableMovement = 20
        view.addGestureRecognizer(gesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let callback: () -> Void

        init(callback: @escaping () -> Void) {
            self.callback = callback
        }

        @objc func action(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                callback()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(callback: callback)
    }
}
