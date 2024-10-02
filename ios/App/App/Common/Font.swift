import SwiftUI

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
}
