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
    var image: AmiImage
    var size: CGSize = CGSize(width: 40, height: 40)

    init(image: AmiImage, size: CGSize = CGSize.avatarThumbnailSize) {
        self.image = image
        self.size = size
    }

    init(imageUrl: URL?, size: CGSize = CGSize.avatarThumbnailSize) {
        self.image = .url(imageUrl)
        self.size = size
    }

    init(uiImage: UIImage, size: CGSize = CGSize.avatarThumbnailSize) {
        self.image = .uiImage(uiImage)
        self.size = size
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                AmiImageView(image: image)
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
            }
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
            ),
            name: "Party",
            image: UIImage()
        )
    )
}
