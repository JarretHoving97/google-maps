//
//  ResolvedViewModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/01/2025.
//

import SwiftUI

// MARK: - Helper: AnyViewModifier
struct ResolvedViewModifier: ViewModifier {
    private let bodyClosure: (Content) -> AnyView

    init<M: ViewModifier>(_ modifier: M) {
        bodyClosure = { content in AnyView(content.modifier(modifier)) }
    }

    func body(content: Content) -> some View {
        bodyClosure(content)
    }
}
