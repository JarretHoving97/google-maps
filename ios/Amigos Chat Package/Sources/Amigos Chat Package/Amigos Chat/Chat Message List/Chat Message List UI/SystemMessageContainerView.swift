//
//  SystemMessageContainerView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/08/2025.
//

import SwiftUI

public struct DefaultSystemMessageView: View {

    private var router: Router?
    let message: Message

    init(router: Router? = nil, message: Message) {
        self.router = router
        self.message = message
    }

    func navigateToProfileWebView() {
        let userId = message.user.id
        router?.push(.client(.profileRoute(id: userId)))
    }

    public var body: some View {
        HStack(spacing: 8) {
            AvatarView(imageUrl: message.user.imageUrl, size: 40)

            VStack(alignment: .leading, spacing: 8) {
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
                messageButtonView
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

    private var messageButtonView: some View {
        Group {
            if let viewData = MessageActionResolver.resolve(from: message) {
                MessageActionButtonView(viewModel: viewData)
            }
        }
    }
}
