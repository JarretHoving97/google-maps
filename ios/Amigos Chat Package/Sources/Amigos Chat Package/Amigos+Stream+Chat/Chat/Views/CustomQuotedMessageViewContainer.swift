import SwiftUI
import StreamChat
import StreamChatSwiftUI

public struct CustomQuotedMessageViewContainer<Factory: ViewFactory>: View {

    @Injected(\.utils) private var utils

    var factory: Factory
    var quotedMessage: ChatMessage
    var fillAvailableSpace: Bool
    var isInComposer: Bool = false
    @Binding var scrolledId: String?

    public var body: some View {
       CustomQuotedMessageView(
            factory: factory,
            quotedMessage: quotedMessage,
            fillAvailableSpace: fillAvailableSpace,
            isInComposer: isInComposer
        )
        .padding(isInComposer ? .all : [.top, .horizontal], 4)
        .onTapGesture(perform: {
            scrolledId = quotedMessage.scrollMessageId
        })
        .accessibilityIdentifier("QuotedMessageViewContainer")
    }
}
