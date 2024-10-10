import SwiftUI
import StreamChat
import StreamChatSwiftUI
import SDWebImageSwiftUI

/// View displaying system messages.
public struct CustomSystemMessageView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var message: ChatMessage

    public init(message: ChatMessage) {
        self.message = message
    }
    
    func navigateToProfileWebView() {
        let userId = message.author.id
        let route = "/profile/\(userId)"
        
        ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: route, dismiss: true)
    }

    public var body: some View {
        HStack(spacing: 8) {
            WebImage(url: message.author.imageURL)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 40, alignment: .center)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                if let name = message.author.name {
                    Text(name)
                        .font(fonts.footnoteBold)
                }
                
                Text(message.text)
                    .font(fonts.caption1)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
        .modifier(ShadowModifier())
        .onTapGesture {
            navigateToProfileWebView()
        }
        .padding(.all, 4)
        .accessibilityIdentifier("SystemMessageView")
    }
}
