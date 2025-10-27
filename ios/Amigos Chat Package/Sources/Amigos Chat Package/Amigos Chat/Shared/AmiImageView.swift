//
//  AmiImageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/10/2025.
//

import SDWebImageSwiftUI
import SwiftUI

struct AmiImageView: View {

    let image: AmiImage

    var body: some View {

        switch image {
        case .url(let url):
            WebImage(url: url)
                .resizable()
        case .uiImage(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
        }
    }
}
