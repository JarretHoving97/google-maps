import SwiftUI

enum Variant: String {
    case defaultCheck = "SafetyCheck"
    case outLined = "SafetyCheckOutlined"
}

struct AmiSafetyCheckIcon: View {

    public let variant: Variant
    public let renderingMode: Image.TemplateRenderingMode

    init(variant: Variant = .defaultCheck, renderingMode: Image.TemplateRenderingMode = .original) {
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
