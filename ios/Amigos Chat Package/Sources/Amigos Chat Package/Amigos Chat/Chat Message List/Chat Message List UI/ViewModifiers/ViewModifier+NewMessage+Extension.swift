//
//  ViewModifier+NewMessage+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 12/06/2025.
//

import SwiftUI

extension View {

    func newMessageIndicator(_ viewModel: NewMessageIndicatorViewModel) -> some View {
        self.modifier(
            NewMessageIndicatorViewModifier(
                viewModel: viewModel
            )
        )
    }
}
