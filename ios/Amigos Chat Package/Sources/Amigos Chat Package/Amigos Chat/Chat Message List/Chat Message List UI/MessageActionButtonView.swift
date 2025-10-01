//
//  MessageActionButton.swift
//  Amigos Chat Package
//
//  Created by Ilon on 11/09/2025.
//

import SwiftUI

struct MessageActionButtonView: View {

    let viewModel: MessageActionButton

    init(viewModel: MessageActionButton) {
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
        RouteController.routeAction?(RouteInfo(route: viewModel.route, dismiss: true))
    }
}
