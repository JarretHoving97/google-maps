//
//  AvatarView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 06/05/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct AvatarView: View {

    let image: AmiImage
    let size: CGFloat

    init(image: AmiImage, size: CGFloat = CGSize.avatarThumbnailSize.width) {
        self.image = image
        self.size = size
    }

    init(imageUrl: URL?, size: CGFloat = CGSize.avatarThumbnailSize.width) {
        self.image = .url(imageUrl)
        self.size = size
    }

    init(uiImage: UIImage, size: CGFloat = CGSize.avatarThumbnailSize.width) {
        self.image = .uiImage(uiImage)
        self.size = size
    }

    init(urlString: String?, size: CGFloat = CGSize.avatarThumbnailSize.width) {
        self.image = .url(URL(string: urlString ?? ""))
        self.size = size
    }

    var body: some View {
        AmiImageView(image: image)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
