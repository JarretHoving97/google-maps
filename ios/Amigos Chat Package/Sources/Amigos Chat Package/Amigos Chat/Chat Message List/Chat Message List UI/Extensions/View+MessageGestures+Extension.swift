//
//  View+.swift
//  Amigos Chat Package
//
//  Created by Jarret on 02/07/2025.
//

import SwiftUI

extension View {

    func messageGestures(
        onSwipe: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> some View {
        self.modifier(
            MessageGesturesModifier(
                onSwipe: onSwipe,
                onLongPress: onLongPress
            )
        )
    }
}
