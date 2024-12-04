import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// View that displays the message author.
public struct CustomMessageAuthorView: View {

    @Injected(\.utils) private var utils
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var message: ChatMessage

    public init(message: ChatMessage) {
        self.message = message
    }

    private var colorByHashingString: Color {
        if let name = message.author.name {
            return getColorByHashingString(name)
        }

        return Color(colors.alternativeActiveTint)
    }

    public var body: some View {
        Text(message.authorDisplayInfo.name)
            .font(Font.custom(size: 12, weight: ThemeFontWeight.bold))
            .lineLimit(1)
            .foregroundColor(colorByHashingString)
            .animation(nil)
            .accessibilityIdentifier("MessageDateView")
    }
}
