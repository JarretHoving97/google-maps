import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// View that displays the sending date of a message.
public struct CustomMessageDateView: View {
    @Injected(\.utils) private var utils
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }

    var message: ChatMessage

    var text: String {
        var text = dateFormatter.string(from: message.createdAt)
        let showMessageEditedLabel = utils.messageListConfig.isMessageEditedLabelEnabled
            && message.textUpdatedAt != nil
            && !message.isDeleted
        if showMessageEditedLabel {
            text = text + " • " + tr("message.cell.edited")
        }
        return text
    }

    public var body: some View {
        Text(text)
            .font(Font.custom(size: 10, weight: ThemeFontWeight.medium))
            .foregroundColor(Color(colors.textLowEmphasis))
            .animation(nil)
            .accessibilityIdentifier("MessageDateView")
    }
}
