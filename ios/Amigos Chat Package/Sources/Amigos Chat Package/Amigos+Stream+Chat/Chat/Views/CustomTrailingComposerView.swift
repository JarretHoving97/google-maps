// swiftlint:disable all
import SwiftUI
import StreamChatSwiftUI

enum ButtonType {
    case Disabled
    case Sendable
    case VoiceRecorder
}

/// View for the button for sending messages.
public struct CustomTrailingComposerView: View {
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    @EnvironmentObject var viewModel: MessageComposerViewModel

    let sendButtonEnabled: Bool
    let cooldownDuration: Int
    let sendMessage: () -> Void

    @State private var longPressed = false
    @State private var longPressStarted: Date?

    public init(sendButtonEnabled: Bool, cooldownDuration: Int, sendMessage: @escaping () -> Void) {
        self.sendButtonEnabled = sendButtonEnabled
        self.cooldownDuration = cooldownDuration
        self.sendMessage = sendMessage
    }

    private var buttonType: ButtonType {
        if sendButtonEnabled {
            // Happens when the user has typed something.
            return .Sendable
        }

//        if ExtendedStreamPlugin.shared.superEntitlementStatus == SuperEntitlementStatus.Active {
//            return .VoiceRecorder
//        }

        return .Disabled
    }

    private var background: Color {
        var color = Color("Purple")

        if buttonType == .Disabled {
            color = color.opacity(0.3)
        }

        return color
    }

    private var systemImage: String {
        if buttonType == .VoiceRecorder {
            return "mic.fill"
        }

        return "paperplane.fill"
    }

    func onDragGestureChange(_ value: DragGesture.Value) {
        if buttonType == .Sendable {
            sendMessage()
        } else if buttonType == .VoiceRecorder {
            if !longPressed {
                longPressStarted = Date()
                longPressed = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if longPressed {
                        viewModel.recordingState = .recording(value.location)
                        viewModel.startRecording()
                    }
                }
            } else if case .recording = viewModel.recordingState {
                viewModel.recordingState = .recording(value.location)
            }
        }
    }

    func onDragGestureEnd() {
        longPressed = false

        if let longPressStarted, Date().timeIntervalSince(longPressStarted) <= 0.15 {
            if viewModel.recordingState != .showingTip {
                viewModel.recordingState = .showingTip
            }
            self.longPressStarted = nil
            return
        }
        if viewModel.recordingState != .locked {
            viewModel.stopRecording()
        }
    }

    public var body: some View {
        HStack {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 16, height: 16, alignment: .center)
                .foregroundColor(Color.white)
                .id(systemImage)
                .transition(.scale.animation(.easeOut))
        }
            .frame(width: 44, height: 44, alignment: .center)
            .background(background)
            .animation(.easeInOut, value: buttonType == .Sendable)
            .clipShape(Circle())
            .disabled(buttonType == .Disabled)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onDragGestureChange(value)
                    }
                    .onEnded { _ in
                        onDragGestureEnd()
                    }
            )
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("SendMessageButton")
    }
}
