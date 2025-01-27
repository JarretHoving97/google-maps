import SwiftUI
import StreamChat

enum MessageWalkthroughType: String {
    case onboardingHowToHost = "onboarding"
    case onboardingHowToJoin = "how_to_host"
    case onboardingDefault = "how_to_join"
}

struct AmiMessageWalkthrough: View {
    public let type: MessageWalkthroughType

    var body: some View {
        HStack {
            if type == .onboardingHowToHost {
                AmiGifImage("walkthrough_03")
                    .frame(width: 75, height: 152, alignment: .center)
            } else if type == .onboardingHowToJoin {
                AmiGifImage("walkthrough_04")
                    .frame(width: 75, height: 152, alignment: .center)
            } else {
                AmiGifImage("walkthrough_01")
                    .frame(width: 75, height: 152, alignment: .center)
            }
        }
        .allowsHitTesting(false)
        .frame(maxWidth: .infinity, minHeight: 152)
        .padding(16)
        .background(Color(hex: "#882CCF"))
    }
}
