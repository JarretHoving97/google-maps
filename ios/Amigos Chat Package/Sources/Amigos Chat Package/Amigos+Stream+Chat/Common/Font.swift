import SwiftUI
import UIKit.UIFont

enum ThemeFontWeight: String {
    case bold = "Bold"
    case semiBold = "SemiBold"
    case medium = "Medium"
    case regular = "Regular"
    case light = "Light"
}

enum ThemeFontStyle: String {
    case normal = ""
    case italic = "Italic"
}

extension Font {

    static func custom(
        size: CGFloat,
        weight: ThemeFontWeight,
        style: ThemeFontStyle = ThemeFontStyle.normal
    ) -> Font {
        let fontName: String = "Poppins-" + weight.rawValue + style.rawValue

        return Font.custom(fontName, size: size)
    }

    static var body: Font {
        Font.custom(size: 15, weight: ThemeFontWeight.regular)
    }

    static var caption1: Font {
        return .custom(size: 13, weight: .regular)
    }

    static var subheadline: Font {
        Font.custom(size: 14, weight: ThemeFontWeight.medium)
    }
}

extension UIFont {

    static var caption1: UIFont {
        return .custom(size: 13, weight: .regular)
    }

    static func custom(
        size: CGFloat,
        weight: ThemeFontWeight,
        style: ThemeFontStyle = ThemeFontStyle.normal
    ) -> UIFont {
        let fontName: String = "Poppins-" + weight.rawValue + style.rawValue

        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
