//
//  SystemMessageContainerView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import SwiftUI

public struct DefaultSystemMessageView: View {

    let message: Message

    public init(message: Message) {
        self.message = message
    }

    func navigateToProfileWebView() {
        let userId = message.user.id
        RouteController.routeAction?(RouteInfo(route: .profileRoute(id: userId), dismiss: true))
    }

    public var body: some View {
        HStack(spacing: 8) {
            AvatarView(imageUrl: message.user.imageUrl, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(message.user.name)
                    .font(.footnote)
                    .fontWeight(.bold)

                Text(
                    message
                        .translationKey?
                        .localizedString(message.user.name) ?? message.text
                )
                    .font(.caption1)
                    .foregroundStyle(Color(.grey))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
        .modifier(ShadowModifier())
        .onTapGesture {
            navigateToProfileWebView()
        }
        .padding(.all, 4)
        .accessibilityIdentifier("SystemMessageView")
    }
}
