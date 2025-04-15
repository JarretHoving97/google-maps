//
//  QuotedLocationView.swift
//  App
//
//  Created by Jarret on 23/12/2024.
//

import SwiftUI

struct QuotedLocationView: View {

    var viewModel: QuotedLocationViewModel

    @State private var presentShareSheet: Bool = false

    init(viewModel: QuotedLocationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            color
            HStack(spacing: 0) {
                Image(.amigosLocationPin)
                    .resizable()
                    .frame(width: 16, height: 16)
                Spacer()
                Text(viewModel.title)
                    .font(
                        Font.custom(
                            size: 12,
                            weight: .regular
                        )
                    )
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.8)

            }
            .foregroundStyle(viewModel.isSentByCurrentUser ? .white : .black)
            .padding(
                EdgeInsets(
                    top: 4,
                    leading: 10,
                    bottom: 4,
                    trailing: 10
                )
            )

        }
        .frame(width: 100, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white, lineWidth: viewModel.isSentByCurrentUser ? 0.5 : 0)
        )
        .onTapGesture {
            presentShareSheet.toggle()
        }
        .shareLocationDialog(
            isPresented: $presentShareSheet,
            title: viewModel.dialogTitle,
            latitude: viewModel.latitude,
            longitude: viewModel.longitude
        )
    }

    private var color: Color {
        !viewModel.isSentByCurrentUser ? Color(.coolerGray) : Color.clear
    }
}
