//
//  Untitled.swift
//  App
//
//  Created by Jarret Hoving on 19/11/2024.
//

import SwiftUI

/// For future searching functionality:
/// https://developer.apple.com/documentation/swiftui/environmentvalues/issearching
struct ShareLocationSearchWrapperView: View {

    @Binding var isPresenting: Bool

    private let viewModel: ShareLocationViewModel

    init(viewModel: ShareLocationViewModel, isPresenting: Binding<Bool>) {
        self.viewModel = viewModel
        _isPresenting = isPresenting
    }

    var body: some View {
        ShareLocationView(
            viewModel: viewModel,
            onCloseTapped: { isPresenting = false }
        )
    }
}
