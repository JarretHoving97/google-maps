import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct AmiThumbButton: View {
    let positive: Bool
    let action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Image("Thumb")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundColor(Color.white)
                .rotationEffect(positive ? .zero : .degrees(180))
                .offset(y: positive ? 0 : 1)
        }
        .frame(width: 32, height: 32)
        .background(Color(positive ? "Green" : "Red"))
        .clipShape(Circle())
    }
}
