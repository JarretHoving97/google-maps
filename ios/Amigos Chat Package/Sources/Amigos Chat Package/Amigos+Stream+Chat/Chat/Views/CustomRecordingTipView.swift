import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomRecordingTipView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    public var body: some View {
        Text(tr("custom.composer.record.holdAndRelease"))
            .font(fonts.caption2)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 0.5)
                    .background(Color(colors.lightBorder)),
                alignment: .top
            )
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
    }
}
