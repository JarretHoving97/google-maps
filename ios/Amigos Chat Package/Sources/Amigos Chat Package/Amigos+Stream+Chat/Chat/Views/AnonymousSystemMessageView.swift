import SwiftUI
import StreamChat
import StreamChatSwiftUI
import SDWebImageSwiftUI

struct AnonymousSystemMessageView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    let message: ChatMessage

    public init(message: ChatMessage) {
        self.message = message
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(message.text)
                .font(fonts.caption1)
                .foregroundColor(Color(colors.textLowEmphasis))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
        .modifier(ShadowModifier())
        .padding(.all, 4)
    }
}
