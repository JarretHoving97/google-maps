import SwiftUI
import StreamChatSwiftUI

public struct CustomChatTitleView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var name: String
    var isRead: Bool

    public var body: some View {
        Text(name)
            .lineLimit(1)
            .font(isRead ? fonts.headline : fonts.headlineBold)
            .foregroundColor(Color(colors.text))
            .accessibilityIdentifier("ChatTitleView")
    }
}
