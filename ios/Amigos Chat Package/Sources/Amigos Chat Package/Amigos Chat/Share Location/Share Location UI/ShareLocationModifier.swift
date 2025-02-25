//
//  ShareLocationModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2025.
//

import SwiftUI

struct ShareLocationModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let latitude: Double
    let longitude: Double

    func body(content: Content) -> some View {
        content
            .confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
                ForEach(
                    ShareLocationURLService.generateShareLocationUrls(
                        latitude: latitude,
                        longitude: longitude
                    ),
                    id: \.self
                ) { option in
                    if let url = option.url {
                        Button(option.name) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            } message: {
                if let message = message {
                    Text(message)
                }
            }
    }
}

extension View {

    func shareLocationDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        latitude: Double,
        longitude: Double
    ) -> some View {
        self.modifier(
            ShareLocationModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                latitude: latitude,
                longitude: longitude
            )
        )
    }
}
