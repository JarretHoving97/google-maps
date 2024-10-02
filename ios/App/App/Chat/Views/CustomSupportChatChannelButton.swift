import SwiftUI

struct CustomSupportChatChannelButton: View {
    
    func navigateToFaqWebView() {
        ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: "/faq", dismiss: true)
    }
    
    var body: some View {
        VStack {
            AmiButton("custom.contact", fluid: true, action: navigateToFaqWebView)
        }
        .padding(.all, 16)
    }
}
