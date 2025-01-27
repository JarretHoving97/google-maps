import SwiftUI
import StreamChatSwiftUI
import StreamChat

public struct CustomAttachmentTextView: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var message: ChatMessage

    public init(message: ChatMessage) {
        self.message = message
    }

    public var body: some View {
        HStack {
            CustomStreamTextView(message: message)
                .standardPadding()
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .background(Color(backgroundColor))
        .accessibilityIdentifier("AttachmentTextView")
    }

    private var backgroundColor: UIColor {
        var colors = colors
        if message.isSentByCurrentUser {
            if message.type == .ephemeral {
                return colors.background8
            } else {
                return colors.messageCurrentUserBackground[0]
            }
        } else {
            return colors.messageOtherUserBackground[0]
        }
    }
}
