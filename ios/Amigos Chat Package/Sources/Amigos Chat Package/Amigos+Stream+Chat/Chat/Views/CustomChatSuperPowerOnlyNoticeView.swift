import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomChatSuperPowerOnlyNoticeView: View {
    @Injected(\.chatRouter) var router
    @Injected(\.fonts) var fonts
    @Injected(\.superStatus) var superStatus

    public var channel: ChatChannel

    private var show: Bool {
        if channel.isSupportChatChannel {
            return false
        }

        if superStatus.superEntitlementStatus != .available {
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
        router?.push(.client(.superAmigoRoute))
    }

    var body: some View {
        if show {
            HStack(spacing: 12) {
                Text(tr("custom.channel.superNotice"))
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
            .background(Color(.noticeHeader))
            .cornerRadius(12)
            .onTapGesture(perform: navigateToSuperAmigoWebView)
            .padding(12)
        }
    }
}
