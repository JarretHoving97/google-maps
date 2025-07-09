//
//  View+Swipeable.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/02/2025.
//

import SwiftUI

extension View {
    func swipeable(onSwipeCompleted: @escaping (() -> Void)) -> some View {
        self.modifier(SwipeableActionGestureModifier(onSwipeCompleted: onSwipeCompleted))
    }
}
