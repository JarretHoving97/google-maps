import SwiftUI

enum Variant: String {
    case Default = "SafetyCheck"
    case Outlined = "SafetyCheckOutlined"
}

struct AmiSafetyCheckIcon: View {
    public let variant: Variant
    public let renderingMode: Image.TemplateRenderingMode
    
    init(variant: Variant = .Default, renderingMode: Image.TemplateRenderingMode = .original) {
        self.variant = variant
        self.renderingMode = renderingMode
    }
    
    var body: some View {
        Image(variant.rawValue)
            .renderingMode(renderingMode)
            .resizable()
            .scaledToFit()
    }
}
