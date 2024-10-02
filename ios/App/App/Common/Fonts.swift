import SwiftUI
import StreamChatSwiftUI

public extension Fonts {
    var title: Font {
        Font.custom(size: 30, weight: ThemeFontWeight.bold)
    }
    
    var title3: Font {
        Font.custom(size: 20, weight: ThemeFontWeight.bold)
    }
    
    var headline: Font { 
        Font.custom(size: 15, weight: ThemeFontWeight.semiBold)
    }
    
    var headlineBold: Font {
        Font.custom(size: 15, weight: ThemeFontWeight.bold)
    }
    
    var subheadline: Font {
        Font.custom(size: 14, weight: ThemeFontWeight.medium)
    }
    
    var subheadlineBold: Font {
        Font.custom(size: 14, weight: ThemeFontWeight.semiBold)
    }
    
    var body: Font {
        Font.custom(size: 15, weight: ThemeFontWeight.regular)
    }
    
    var bodyBold: Font {
        Font.custom(size: 15, weight: ThemeFontWeight.medium)
    }
    
    var bodyItalic: Font {
        Font.custom(size: 15, weight: ThemeFontWeight.regular, style: ThemeFontStyle.italic)
    }
    
    var footnote: Font {
        Font.custom(size: 12, weight: ThemeFontWeight.medium)
    }
    
    var footnoteBold: Font {
        Font.custom(size: 12, weight: ThemeFontWeight.semiBold)
    }
    
    var caption1: Font {
        Font.custom(size: 13, weight: ThemeFontWeight.regular)
    }
    
    var caption2: Font {
        Font.custom(size: 11, weight: ThemeFontWeight.medium)
    }
}
