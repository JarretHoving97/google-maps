import SwiftUI

struct AmiIconButton<Content: View>: View {
    let action: (() -> Void)?
    let color: Color
    let disabled: Bool
    let content: () -> Content

    init(
        action: (() -> Void)?,
        color: Color = Color("Purple"),
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.color = color
        self.disabled = disabled
        self.content = content
    }

    var body: some View {
        Button {
            action?()
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .contentShape(Circle())

                content()
            }
        }
        .buttonStyle(.plain)
        .opacity(disabled ? 0.2 : 1)
        .animation(.easeInOut(duration: 0.3), value: disabled)
        .disabled(disabled)
    }
}
