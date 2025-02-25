//
//  LocationView.swift
//  App
//
//  Created by Jarret Hoving on 19/11/2024.
//

import SwiftUI

struct LocationCell: View {

    let title: String
    let distance: String

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "location")
                .resizable()
                .frame(width: 24, height: 24)
            VStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)

                Text(distance)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Image(.chevronRight)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 14)
        }

        .frame(maxWidth: .infinity)
        .frame(height: 77)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
