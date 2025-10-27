//
//  AmiImage.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/10/2025.
//

import Foundation
import UIKit.UIImage

enum AmiImage {
    case url(URL?)
    case uiImage(UIImage)

    static func urlImage(_ url: URL?) -> Self {
        return .url(url)
    }

    static func image(_ uiImage: UIImage) -> Self {
        return .uiImage(uiImage)
    }
}
