//
//  CommunityChatImageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/08/2025.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit.UIImage

public struct CommunityChatImageView: View {
    var url: URL?
    var size: CGSize = CGSize(width: 40, height: 40)

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebImage(url: url)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)

                .clipShape(Circle())
                .background(Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: size.width, height: size.height))

            communityIcon
        }
    }

    var communityIcon: some View {
        ZStack {
            Color(.greyLight)
            Image(uiImage: UIImage(named: "communityChatIcon", in: .module, with: .none)!)
        }
        .clipShape(Circle())
        .frame(width: 16, height: 16)
    }
}

#Preview {
    ChatChannelCell(
        viewModel: ChatChannelCellViewModel(
            channel: LocalChannel(
                id: UUID().uuidString,
                name: "Bar marathon",
                imageURL: ImageURLExamples.Interests.coffeeURL,
                lastMessageAt: Date(),
                unreadCount: LocalChannelUnreadCount(
                    messages: 4,
                    mentions: 0
                ),
                subtitleText: "Ilon: Meet me at the park"
            )
        )
    )
}
