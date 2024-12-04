import SwiftUI
import StreamChatSwiftUI

struct AmiChatTrialNoticeView: View {
    @Injected(\.fonts) var fonts

    @State private var isChatTrialNoticeSheetPresented = false

    let now = Date()

    let daysInPeriod = 30

    var chatTrialUntil: Date? {
        ExtendedStreamPlugin.shared.chatTrialUntil
    }

    var remainingTrialDays: Int? {
        let chatTrialUntil = ExtendedStreamPlugin.shared.chatTrialUntil
        let isSuperAvailable = ExtendedStreamPlugin.shared.superEntitlementStatus == .Available

        guard let chatTrialUntil, isSuperAvailable else {
            return nil
        }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let startOfTrialEnd = calendar.startOfDay(for: chatTrialUntil)

        return calendar.dateComponents([.day], from: startOfToday, to: startOfTrialEnd).day
    }

    var show: Bool {
        guard let remainingTrialDays else {
            return false
        }

        return remainingTrialDays > 0
    }

    var showProgressBar: Bool {
        guard let remainingTrialDays else {
            return false
        }

        // As of now the length of the period is always 30 days. If it's above that, we don't
        // know how long the period was when it started so we can't display the progress bar.

        return remainingTrialDays > 0 && remainingTrialDays <= daysInPeriod
    }

    var body: some View {
        if show, let remainingDays = remainingTrialDays {
            VStack {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Grey Light"))
                                .frame(width: 40, height: 40)

                            Text("\(remainingDays)")
                                .font(fonts.bodyBold)
                                .foregroundStyle(Color("Grey Dark"))
                        }

                        Text(tr("custom.chatTrialNotice.title", remainingDays))
                            .fixedSize(horizontal: false, vertical: true)
                            .font(fonts.caption1)
                            .foregroundStyle(Color("Grey Dark"))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 12, height: 12, alignment: .center)
                            .foregroundColor(Color("Purple"))
                    }

                    if showProgressBar {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("Grey Light"))

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("Purple"))
                                    .frame(width: min(CGFloat(remainingDays) / CGFloat(daysInPeriod), 1.0) * geometry.size.width)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding(.all, 8)
                .background(Color("Pale"))
                .cornerRadius(8)
                .onTapGesture {
                    isChatTrialNoticeSheetPresented = true
                }
                .chatSheetPresentation(
                    isPresented: $isChatTrialNoticeSheetPresented,
                    detents: [.medium()]
                ) {
                    CustomChatTrialNoticeView(
                        isPresented: $isChatTrialNoticeSheetPresented,
                        remainingTrialDays: remainingDays
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        } else {
            EmptyView()
        }
    }
}

struct CustomChatTrialNoticeView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    @Binding var isPresented: Bool

    private var remainingTrialDays: Int

    public init(isPresented: Binding<Bool>, remainingTrialDays: Int) {
        _isPresented = isPresented
        self.remainingTrialDays = remainingTrialDays
    }

    func navigateToSuperAmigoWebView() {
        ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: "/super-amigo", dismiss: true)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            ReflectiveNumberView(days: remainingTrialDays)

            VStack(alignment: .leading, spacing: 8) {
                Text(tr("custom.chatTrialNotice.dialog.title", 30))
                    .fixedSize(horizontal: false, vertical: true)
                    .font(fonts.title)

                Text(tr("custom.chatTrialNotice.dialog.body", 30))
                    .fixedSize(horizontal: false, vertical: true)
                    .font(fonts.body)
            }

            Spacer()

            AmiButton("custom.becomeSuperAmigo") {
                navigateToSuperAmigoWebView()
            }
                .frame(maxWidth: .infinity)
        }
        .padding(.all, 16)
        .padding(.top, 24)
        .background(Color("White"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}

struct ReflectiveNumberView: View {
    public var days: Int

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Text("30")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.black)

                Text("30")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.gray.opacity(0.4))
                    .scaleEffect(y: -1)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]),
                            startPoint: .top,
                            endPoint: UnitPoint(x: 0.5, y: 0.75)
                        )
                    )
                    .offset(y: 39)
            }
        }
        .frame(width: 112, height: 112)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("Pale"), lineWidth: 8)
        )
    }
}
