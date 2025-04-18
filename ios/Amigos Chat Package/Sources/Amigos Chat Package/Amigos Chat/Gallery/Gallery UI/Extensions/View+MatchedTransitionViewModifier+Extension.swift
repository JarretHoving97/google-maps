//
//  View+MatchedTransitionViewModifier+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/04/2025.
//

import SwiftUI

extension View {

    func matchedTransitionSourceIfAvailable(sourceID: AnyHashable, animation: Namespace.ID) -> some View {
        self.modifier(MatchedTransitionSourceModifier(sourceID: sourceID, animation: animation))
    }

    func navigationTransitionIfAvailable(sourceID: AnyHashable, animation: Namespace.ID) -> some View {
        self.modifier(NavigationTransitionModifier(sourceID: sourceID, animation: animation))
    }
}
