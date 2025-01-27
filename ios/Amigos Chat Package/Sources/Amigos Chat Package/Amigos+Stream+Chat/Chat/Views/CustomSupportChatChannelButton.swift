import SwiftUI

struct CustomSupportChatChannelButton: View {

    func navigateToFaqWebView() {
        RouteController.routeAction?(RouteInfo(route: .faq, dismiss: true))
    }

    var body: some View {
        VStack {
            AmiButton("custom.contact", fluid: true, action: navigateToFaqWebView)
        }
        .padding(.all, 16)
    }
}
