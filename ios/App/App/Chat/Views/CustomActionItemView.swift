import SwiftUI
import StreamChatSwiftUI

/// View for the  action item in an action list (for channels and messages).
public struct CustomActionItemView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts

    var title: String
    var iconName: String
    var isDestructive: Bool

    public var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(fonts.body)
                .foregroundColor(
                    isDestructive ? Color("Red") : Color(colors.text)
                )

            Spacer()

            Image(systemName: iconName)
                .customizable()
                .frame(maxWidth: 16, maxHeight: 16)
                .foregroundColor(
                    isDestructive ? Color("Red") : Color(colors.textLowEmphasis)
                )
        }
        .contentShape(Rectangle())
    }
}
