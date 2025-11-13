//
//  View+.swift
//  Amigos Chat Package
//
//  Created by Jarret on 02/07/2025.
//

import SwiftUI

extension View {

    func messageGestures(
        disabled: Bool = false,
        onSwipe: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> some View {
        self.modifier(
            MessageGesturesModifier(
                disabled: disabled,
                onSwipe: onSwipe,
                onLongPress: onLongPress
            )
        )
    }
}
