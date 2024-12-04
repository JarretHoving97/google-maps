import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomChatSuperPowerOnlyNoticeView: View {
    @Injected(\.fonts) var fonts

    public var channel: ChatChannel

    private var show: Bool {
        if channel.isSupportChatChannel {
            return false
        }

        if ExtendedStreamPlugin.shared.superEntitlementStatus != .Available {
            return false
        }

        // The date we restricted private chats to be only accessible to hosts and Super amigos.
        let restrictedAt = "2024-06-20T00:00:00Z"

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let referenceDate = formatter.date(from: restrictedAt) else {
            return false
        }

        return channel.createdAt > referenceDate
    }

    func navigateToSuperAmigoWebView() {
        ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: "/super-amigo", dismiss: true)
    }

    var body: some View {
        if show {
            HStack(spacing: 12) {
                Text("custom.channel.superNotice")
                    .font(fonts.caption2)

                Spacer()

                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 12, height: 12, alignment: .center)
                    .foregroundColor(Color("Purple"))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: 8, x: 0, y: 2)
            .onTapGesture(perform: navigateToSuperAmigoWebView)
            .padding(12)
        }
    }
}
