//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import StreamChatSwiftUI

class VoiceRecordingHandler: ObservableObject, AudioPlayingDelegate {

    @Published var context: AudioPlaybackContext = .notLoaded

    func audioPlayer(
        _ audioPlayer: AudioPlaying,
        didUpdateContext context: AudioPlaybackContext
    ) {
        self.context = context
    }
}

struct CustomLockedView: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils

    @ObservedObject var viewModel: MessageComposerViewModel
    @State var isPlaying = false
    @State var showLockedIndicator = true
    @StateObject var voiceRecordingHandler = VoiceRecordingHandler()

    @State private var pulseOpacity: Double = 1.0
    @State private var scaleSize: CGFloat = 1

    private var player: AudioPlaying {
        utils.audioPlayer
    }

    var body: some View {
        HStack(spacing: 12) {
            if viewModel.recordingState == .locked {
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
            } else {
                Button {
                    handlePlayTap()
                } label: {
                    ZStack {
                        Image(systemName: isPlaying ? "pause" : "play")
                            .resizable()
                            .scaledToFit()
                            .offset(x: isPlaying ? 0 : 2)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 16, height: 16, alignment: .center)
                            .foregroundColor(Color.white)
                    }
                        .frame(width: 38, height: 38, alignment: .center)
                        .background(Color("Purple"))
                        .clipShape(Circle())
                }
            }

            CustomRecordingDurationView(
                duration: showContextTime ?
                    voiceRecordingHandler.context.currentTime : viewModel.audioRecordingInfo.duration
            )

            CustomRecordingWaveform(
                duration: viewModel.audioRecordingInfo.duration,
                currentTime: viewModel.recordingState == .stopped ?
                    voiceRecordingHandler.context.currentTime :
                    viewModel.audioRecordingInfo.duration,
                waveform: viewModel.audioRecordingInfo.waveform,
                foregroundStyleDark: true
            )
            .frame(height: 30)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    withAnimation {
                        viewModel.discardRecording()
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .scaledToFit()
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 16, height: 16, alignment: .center)
                        .foregroundColor(Color.white)
                }
                .frame(width: 38, height: 38, alignment: .center)
                .background(Color.red)
                .clipShape(Circle())

                if viewModel.recordingState == .locked {
                    Button {
                        withAnimation {
                            viewModel.previewRecording()
                        }
                    } label: {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .scaledToFit()
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 16, height: 16, alignment: .center)
                            .foregroundColor(Color.white)
                    }
                    .frame(width: 38, height: 38, alignment: .center)
                    .background(Color.blue)
                    .clipShape(Circle())
                }

                Button {
                    withAnimation {
                        viewModel.confirmRecording()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .scaledToFit()
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 16, height: 16, alignment: .center)
                        .foregroundColor(Color.white)
                }
                .frame(width: 38, height: 38, alignment: .center)
                .background(Color("Purple"))
                .clipShape(Circle())
            }
        }
        .padding(.horizontal, 12)
        .onAppear {
            player.subscribe(voiceRecordingHandler)
        }
        .onReceive(voiceRecordingHandler.$context, perform: { value in
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        })
    }

    private var showContextTime: Bool {
        voiceRecordingHandler.context.currentTime > 0
    }

    private func handlePlayTap() {
        if isPlaying {
            player.pause()
        } else if let url = viewModel.pendingAudioRecording?.url {
            player.loadAsset(from: url)
        }
        isPlaying.toggle()
    }
}
