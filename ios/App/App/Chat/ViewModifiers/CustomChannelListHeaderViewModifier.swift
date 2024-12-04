import SwiftUI
import StreamChatSwiftUI
import UIKit
import Capacitor

struct CustomChannelListHeaderViewModifier: ChannelListHeaderViewModifier {

    @Injected(\.fonts) var fonts
    @Injected(\.images) var images

    @State var profileShown = false

    var title: String

    init(title: String) {
        self.title = title
        updateAppearance()
    }

    func updateAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()

        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color.white)
        navigationBarAppearance.shadowColor = UIColor.clear
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color("Grey Dark")),
            .font: UIFont(name: "Poppins-Bold", size: 30)!,
            .baselineOffset: 12
        ]
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color("Grey Dark")),
            .font: UIFont(name: "Poppins-Bold", size: 15)!
        ]

        UINavigationBar.appearance().layoutMargins.left = 16
        UINavigationBar.appearance().layoutMargins.right = 16
        UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HeaderButtonView {
                    ExtendedStreamPlugin.shared.notifyNavigateBackToListeners(dismiss: true)
                }
                .padding(.leading, -14)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("custom.channelList.title")
    }
}
