//
//  ShareLocationMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 03/02/2025.
//

import SwiftUI

public struct ShareLocationMessageView: View {

    @StateObject private var viewModel: CustomShareLocationMessageViewModel

    private let width: CGFloat

    public init(
        viewModel: CustomShareLocationMessageViewModel,
        width: CGFloat = .messageWidth
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.width = width
    }

    public var body: some View {

        VStack {
            usersLocationView
        }
        .frame(maxWidth: width, alignment: .leading)
        .onTapGesture {
            viewModel.presentShareSheet.toggle()
        }
        .shareLocationDialog(
            isPresented: $viewModel.presentShareSheet,
            title: viewModel.dialogTitle,
            latitude: viewModel.latitude,
            longitude: viewModel.longitude
        )
    }

    private var usersLocationView: some View {

        VStack(spacing: 0) {
            ZStack {
                Color(.purple)
                Image(systemName: "map")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)

            }
            .frame(height: 60)
            ZStack {
                Color(uiColor: .white)
                HStack {
                    Text(viewModel.authorLocationLabel)
                        .lineLimit(1)
                        .font(.caption1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(.chevronRight)
                        .foregroundStyle(Color(.purple))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}
