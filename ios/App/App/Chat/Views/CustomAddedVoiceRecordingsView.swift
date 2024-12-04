import StreamChat
import SwiftUI
import StreamChatSwiftUI

struct CustomAddedVoiceRecordingsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    @StateObject var voiceRecordingHandler = VoiceRecordingHandler()

    var addedVoiceRecordings: [AddedVoiceRecording]
    var onDiscardAttachment: (String) -> Void

    public init(addedVoiceRecordings: [AddedVoiceRecording], onDiscardAttachment: @escaping (String) -> Void) {
        self.addedVoiceRecordings = addedVoiceRecordings
        self.onDiscardAttachment = onDiscardAttachment
    }

    private var player: AudioPlaying {
        utils.audioPlayer
    }

    public var body: some View {
        VStack {
            ForEach(0..<addedVoiceRecordings.count, id: \.self) { _ in
                let recording = addedVoiceRecordings[0]
                CustomVoiceRecordingView(
                    handler: voiceRecordingHandler,
                    addedVoiceRecording: AddedVoiceRecording(
                        url: recording.url,
                        duration: recording.duration,
                        waveform: recording.waveform
                    ),
                    index: 0,
                    foregroundStyleDark: true
                )
                .padding(.all, 8)
                .padding(.trailing, 8)
                .background(Color(colors.background))
                .id(recording.url)
                .roundWithBorder()
                .overlay(
                    DiscardAttachmentButton(
                        attachmentIdentifier: recording.url.absoluteString,
                        onDiscard: onDiscardAttachment
                    )
                )
            }
        }
        .onAppear {
            player.subscribe(voiceRecordingHandler)
        }
    }
}
