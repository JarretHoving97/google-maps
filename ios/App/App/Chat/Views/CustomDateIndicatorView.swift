import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomDateIndicatorView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var dateString: String

    public init(date: Date) {
        dateString = DateFormatter.messageListDateOverlay.string(from: date)
    }

    public init(dateString: String) {
        self.dateString = dateString
    }

    public var body: some View {
        VStack {
            Text(dateString)
                .font(fonts.caption2)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .foregroundColor(Color(colors.textLowEmphasis))
                .background(Color.white)
                .cornerRadius(16)
                .padding(.all, 12)
                .modifier(ShadowModifier())
            
            Spacer()
        }
    }
}
