//
//  MessageActionButton.swift
//  Amigos Chat Package
//
//  Created by Ilon on 11/09/2025.
//

import SwiftUI

struct MessageActionButtonView: View {

    let router: AnyRouter<ChatRoute>?

    let viewModel: MessageActionButton

    init(viewModel: MessageActionButton, router: AnyRouter<ChatRoute>? = nil) {
        self.router = router
        self.viewModel = viewModel
    }

    var body: some View {
        AmiButton(
            viewModel.title,
            size: .small,
            theme: viewModel.buttonTheme,
            action: navigate
        )
        .padding(.bottom, 6)
    }

    private func navigate() {
        router?.push(.client(viewModel.route))
    }
}
