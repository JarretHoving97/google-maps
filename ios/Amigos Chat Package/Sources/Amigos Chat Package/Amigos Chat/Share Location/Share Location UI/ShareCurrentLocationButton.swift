//
//  ShareCurrentLocationButton.swift
//  App
//
//  Created by Jarret Hoving on 19/11/2024.
//

import SwiftUI

struct ShareCurrentLocationButton: View {

    var viewModel: ShareCurrentLocationViewModel

    var onTap: (() -> Void)

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                VStack {
                    Text(viewModel.title)
                        .font(Font.custom(size: 18, weight: .semiBold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .minimumScaleFactor(0.5)

                    if let subtitle = viewModel.subtitle {
                        Text(subtitle)
                            .font(Font.custom(size: 16, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color(.systemGray5))
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                }
                .frame(maxWidth: .infinity, alignment: .center)

                Image(.chevronRight)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 8))
            .frame(maxWidth: .infinity)
            .frame(height: 77)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))

        }
        .onTapGesture(perform: onTap)
    }
}
