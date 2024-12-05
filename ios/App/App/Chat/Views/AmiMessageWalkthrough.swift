// swiftlint:disable all
import SwiftUI
import StreamChat

enum MessageWalkthroughType: String {
    case OnboardingHowToHost = "onboarding"
    case OnboardingHowToJoin = "how_to_host"
    case OnboardingDefault = "how_to_join"
}

struct AmiMessageWalkthrough: View {
    public let type: MessageWalkthroughType

    var body: some View {
        HStack {
            if type == .OnboardingHowToHost {
                AmiGifImage("walkthrough_03")
                    .frame(width: 75, height: 152, alignment: .center)
            } else if type == .OnboardingHowToJoin {
                AmiGifImage("walkthrough_04")
                    .frame(width: 75, height: 152, alignment: .center)
            } else {
                AmiGifImage("walkthrough_01")
                    .frame(width: 75, height: 152, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 152)
        .padding(16)
        .background(Color(hex: "#882CCF"))
    }
}
