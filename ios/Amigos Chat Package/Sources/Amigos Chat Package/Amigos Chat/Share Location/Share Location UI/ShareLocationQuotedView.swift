//
//  ShareLocationQuotedView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2025.
//

import SwiftUI

struct ShareLocationQuotedView: View {

    var body: some View {

        QuotedLocationView(
            viewModel: QuotedLocationViewModel(
                locationAttachment: LocationAttachment(id: UUID(), latitudeDouble: .zero, longitudeDouble: .zero),
                isSentByCurrentUser: false
            )
        )
        .disabled(true)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
