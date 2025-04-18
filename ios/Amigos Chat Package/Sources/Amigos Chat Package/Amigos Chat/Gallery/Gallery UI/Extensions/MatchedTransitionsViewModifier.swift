//
//  MatchedTransitionsViewModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/04/2025.
//

import SwiftUI

struct NavigationTransitionModifier: ViewModifier {
    let sourceID: AnyHashable
    let animation: Namespace.ID

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                // with the xcode 16 version we can make use of this API
                /* .navigationTransition(.zoom(sourceID: sourceID, in: animation)) */
        } else {
            content
        }
    }
}

struct MatchedTransitionSourceModifier: ViewModifier {
    let sourceID: AnyHashable
    let animation: Namespace.ID

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                // with the xcode 16 version we can make use of this API
               /* .matchedTransitionSource(id: sourceID, in: animation) */
        } else {
            content
        }
    }
}
