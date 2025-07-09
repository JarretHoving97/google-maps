//
//  EmojiImageHelper.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import UIKit

class EmojiImageHelper {

    static func toImage(from string: String, size: CGFloat) -> UIImage {
        let nsString = string
        let font = UIFont.systemFont(ofSize: size)
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
}
