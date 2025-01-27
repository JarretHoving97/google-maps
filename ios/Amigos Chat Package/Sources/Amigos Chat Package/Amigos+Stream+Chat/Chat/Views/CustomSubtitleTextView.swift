import SwiftUI
import StreamChatSwiftUI

/// View for displaying subtitle text.
public struct CustomSubtitleText: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .lineLimit(1)
            .font(fonts.caption2)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}
