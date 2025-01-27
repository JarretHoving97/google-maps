import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// View that displays the read indicator for a message.
public struct CustomMessageReadIndicatorView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var isRead: Bool
    var isReadByAll: Bool
    var localState: LocalMessageState?

    public init(isRead: Bool, isReadByAll: Bool, localState: LocalMessageState? = nil) {
        self.isRead = isRead
        self.isReadByAll = isReadByAll
        self.localState = localState
    }

    public var body: some View {
        HStack(spacing: 2) {
            if localState == .pendingSend {
                Image(uiImage: images.messageReceiptSending)
            } else if isReadByAll {
                Image(uiImage: images.readByAll).renderingMode(.template).foregroundColor(Color.purple)
            } else if isRead {
                Image(uiImage: images.messageSent).renderingMode(.template).foregroundColor(Color.purple)
            } else {
                Image(uiImage: images.messageSent)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageReadIndicatorView")
    }
}
