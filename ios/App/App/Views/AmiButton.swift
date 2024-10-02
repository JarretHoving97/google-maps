import SwiftUI
import StreamChatSwiftUI

struct AmiButton: View {
    @Injected(\.fonts) var fonts
    
    let key: LocalizedStringKey
    var fluid: Bool
    var disabled: Bool
    let action: (() -> Void)?
    
    init(
        _ key: LocalizedStringKey,
        fluid: Bool = true,
        disabled: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.key = key
        self.action = action
        self.fluid = fluid
        self.disabled = disabled
    }
    
    var background: Color {
        var color = Color("Purple")
        
        if disabled {
            color = color.opacity(0.3)
        }
        
        return color
    }
    
    var body: some View {
        Button(action: { action?() }) {
            Text(key)
                .frame(maxWidth: fluid ? .infinity : nil)
                .contentShape(Rectangle())
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .foregroundColor(.white)
                .opacity(1)
                .background(background)
                .cornerRadius(100)
                .font(fonts.subheadline)
        }
            .buttonStyle(.plain)
            .disabled(disabled)
    }
}
