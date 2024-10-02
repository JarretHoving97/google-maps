import StreamChat
import SwiftUI
import StreamChatSwiftUI

struct CustomEmptyChannelsView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            VStack(spacing: 32) {
                Image(systemName: "ellipsis.message.fill")
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 64))
                    .foregroundColor(Color(colors.textLowEmphasis))
                
                Text("custom.channelList.empty")
                    .font(fonts.caption1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(colors.subtitleText))
            }
            .padding(.horizontal, 32)
            .offset(y: -32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        
    }
}
