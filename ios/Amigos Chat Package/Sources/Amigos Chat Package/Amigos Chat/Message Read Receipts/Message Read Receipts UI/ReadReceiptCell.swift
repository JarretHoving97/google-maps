//
//  ReadReceiptCell.swift
//  Amigos Chat Package
//
//  Created by Jarret on 16/01/2026.
//

import SwiftUI

struct ReadReceiptCell: View {

    let viewModel: ReadReceiptCellViewModel

    private let rowSize: CGFloat = 40

    var body: some View {

        HStack(spacing: 10) {

            AvatarView(image: .url(viewModel.avatarImageUrl), size: rowSize)

            Text(viewModel.title)
                .lineLimit(1)
                .font(.body)
                .foregroundColor(Color(.black))

            Spacer()

        }
        .frame(height: rowSize)
    }
}
