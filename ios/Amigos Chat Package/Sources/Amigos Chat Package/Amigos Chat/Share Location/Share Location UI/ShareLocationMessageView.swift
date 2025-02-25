//
//  ShareLocationMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 03/02/2025.
//

import SwiftUI

public struct ShareLocationMessageView: View {

    private var viewModel: CustomShareLocationMessageViewModel
    private let width: CGFloat
    @State private var presentShareSheet: Bool = false

    public init(viewModel: CustomShareLocationMessageViewModel, width: CGFloat = .messageWidth) {
        self.viewModel = viewModel
        self.width = width
    }

    public var body: some View {

        VStack {
            usersLocationView
                .onTapGesture {
                    presentShareSheet.toggle()
                }
        }
        .frame(maxWidth: width, alignment: .leading)
        .shareLocationDialog(
            isPresented: $presentShareSheet,
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
                        .font(Font.custom(size: 16, weight: .regular, style: .normal))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(.chevronRight)
                        .foregroundStyle(Color(.purple))
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 50)
        }
    }
}
