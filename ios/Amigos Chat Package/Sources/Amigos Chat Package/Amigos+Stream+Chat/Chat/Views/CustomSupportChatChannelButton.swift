import SwiftUI
import StreamChatSwiftUI

struct CustomSupportChatChannelButton: View {

    @Injected(\.chatRouter) var router

    func navigateToFaqWebView() {
        router?.push(.client(.faq))
    }

    var body: some View {
        VStack {
            AmiButton(tr("custom.contact"), fluid: true, action: navigateToFaqWebView)
        }
        .padding(.all, 16)
    }
}
