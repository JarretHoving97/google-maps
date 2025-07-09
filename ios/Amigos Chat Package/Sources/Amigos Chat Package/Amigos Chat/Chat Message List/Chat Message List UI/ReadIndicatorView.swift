//
//  ReadIndicatorView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 03/03/2025.
//

import SwiftUI

struct ReadIndicatorView: View {

    @ObservedObject var viewModel: ReadIndicatorViewModel

    init(viewModel: ReadIndicatorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(uiImage: viewModel.icon ?? UIImage())
                .foregroundStyle(viewModel.tintColor ?? .clear)
        }
    }
}
