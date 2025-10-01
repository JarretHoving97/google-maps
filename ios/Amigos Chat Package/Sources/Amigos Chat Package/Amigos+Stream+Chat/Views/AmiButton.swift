import SwiftUI
import StreamChatSwiftUI

enum AmiButtonTheme: String {
    case purple = "Purple"
    case white = "White"
}

enum AmiButtonSize {
    case small
    case medium

    var scale: CGFloat {
        switch self {
        case .small: 0.8
        case .medium: 1.0
        }
    }
}

struct AmiButton: View {
    @Injected(\.fonts) var fonts

    let text: String
    var fluid: Bool
    var disabled: Bool
    let size: AmiButtonSize
    let theme: AmiButtonTheme
    let action: (() -> Void)?

    init(
        _ key: String,
        fluid: Bool = true,
        disabled: Bool = false,
        size: AmiButtonSize = AmiButtonSize.medium,
        theme: AmiButtonTheme = AmiButtonTheme.purple,
        action: (() -> Void)? = nil
    ) {
        self.text = key
        self.action = action
        self.fluid = fluid
        self.disabled = disabled
        self.theme = theme
        self.size = size
    }

    var textColor: Color {
        if theme == AmiButtonTheme.white {
            return Color("Purple")
        }

        return Color(.white)
    }

    var backgroundColor: Color {
        var color = Color("Purple")

        if theme == AmiButtonTheme.white {
            color = Color(.white)
        }

        if disabled {
            color = color.opacity(0.3)
        }

        return color
    }

    var body: some View {
        Button {
            action?()
        } label: {
            Text(text)
                .frame(maxWidth: fluid ? .infinity : nil)
                .contentShape(Rectangle())
                .padding(.horizontal, 24 * size.scale)
                .padding(.vertical, 12 * size.scale)
                .foregroundColor(textColor)
                .opacity(1)
                .background(backgroundColor)
                .cornerRadius(100)
                .font(Font.custom(size: 14 * size.scale, weight: ThemeFontWeight.medium))
        }
            .buttonStyle(.plain)
            .disabled(disabled)
    }
}
