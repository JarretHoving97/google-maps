import StreamChat
import SwiftUI
import StreamChatSwiftUI

// Only change the values below if all usages of `StreamChatSwiftUI.RecordingConstants` are changed.
enum RecordingConstants {
    static let lockMaxDistance: CGFloat = -36
    static let cancelMinDistance: CGFloat = -30
    static let cancelMaxDistance: CGFloat = -75
}

public struct CustomRecordingView: View {

    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    @Injected(\.fonts) var fonts

    var location: CGPoint
    var audioRecordingInfo: AudioRecordingInfo
    var onMicTap: () -> Void

    @State private var pulseOpacity: Double = 1.0
    @State private var scaleSize: CGFloat = 1

    private let initialLockOffset: CGFloat = -102

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "record.circle.fill")
                .resizable()
                .scaledToFit()
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 20, height: 20, alignment: .center)
                .foregroundColor(Color.red)
                .opacity(pulseOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                        pulseOpacity = 0.3
                    }
                }

            CustomRecordingDurationView(duration: audioRecordingInfo.duration)

            Spacer()

            HStack {
                HStack(spacing: 2) {
                    ForEach(Array(0..<3), id: \.self) { _ in
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 8, alignment: .center)
                    }
                }

                Text("custom.composer.voice.slideToCancel")
                    .font(fonts.footnote)
            }
            .foregroundColor(Color(colors.textLowEmphasis))
            .opacity(opacityForSlideToCancel)
            .padding(.horizontal, 36)

            Button {
                onMicTap()
            } label: {
                Circle()
                    .frame(width: 38, height: 38, alignment: .center)
                    .background(Color("Purple"))
                    .clipShape(Circle())
                    .scaleEffect(scaleSize)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            scaleSize = 2.5
                        }
                    }
            }
        }
        .padding(.horizontal, 12)
        .overlay(
            TopRightView {
                CustomLockView()
                    .padding(.all, 12)
                    .offset(y: lockViewOffset)
            }
        )
    }

    private var lockViewOffset: CGFloat {
        if location.y > 0 {
            return initialLockOffset
        }
        return initialLockOffset + location.y
    }

    private var opacityForSlideToCancel: CGFloat {
        guard location.x < RecordingConstants.cancelMinDistance else { return 1 }
        let opacity = (1 - location.x / RecordingConstants.cancelMaxDistance)
        return opacity
    }
}

struct CustomRecordingDurationView: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.fonts) var fonts

    var duration: TimeInterval

    var body: some View {
        Text(utils.videoDurationFormatter.format(duration) ?? "")
            .font(fonts.headline)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}

struct CustomLockView: View {
    @Injected(\.colors) var colors

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16, alignment: .center)

            VStack(spacing: 2) {
                ForEach(Array(0..<3), id: \.self) { _ in
                    Image(systemName: "chevron.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8, alignment: .center)
                }
            }
        }
        .padding(.all, 12)
        .padding(.vertical, 6)
        .foregroundColor(Color("Purple"))
        .background(Color(colors.background8))
        .cornerRadius(16)
        .modifier(ShadowModifier())
    }
}
