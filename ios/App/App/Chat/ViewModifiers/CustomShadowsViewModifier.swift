import SwiftUI
import StreamChatSwiftUI

/// Modifier for adding shadow and corner radius to a view.
struct ShadowViewModifier: ViewModifier {
    @Injected(\.colors) private var colors

    var cornerRadius: CGFloat = 16
    var firstRadius: CGFloat = 10
    var firstY: CGFloat = 12
    
    func body(content: Content) -> some View {
        content.background(Color(UIColor.systemBackground))
            .cornerRadius(cornerRadius)
            .modifier(ShadowModifier())
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color(colors.innerBorder),
                        lineWidth: 0.5
                    )
            )
    }
}

/// Modifier for adding shadow to a view.
public struct ShadowModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.08), radius: 16, x: 0, y: 2)
    }
}
