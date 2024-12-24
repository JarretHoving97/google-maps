import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// View that displays the message author.
public struct CustomMessageAuthorAndDateView: View {

    @Injected(\.utils) private var utils

    public var message: ChatMessage

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            CustomMessageAuthorView(message: message)

            if utils.messageListConfig.messageDisplayOptions.showMessageDate {
                CustomMessageDateView(message: message)
                    .accessibilityIdentifier("MessageDateView")
            }
        }
    }
}
