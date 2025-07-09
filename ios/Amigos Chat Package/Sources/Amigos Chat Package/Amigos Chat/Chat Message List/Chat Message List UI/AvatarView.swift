//
//  AvatarView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 06/05/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct AvatarView: View {

    let imageUrl: URL?
    let size: CGFloat

    init(imageUrl: URL?, size: CGFloat = 32) {
        self.imageUrl = imageUrl
        self.size = size
    }

    init(urlString: String?, size: CGFloat = 32) {
        self.imageUrl = URL(string: urlString ?? "")
        self.size = size
    }

    var body: some View {
        WebImage(url: imageUrl)
            .resizable()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
