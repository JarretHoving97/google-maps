import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomVoiceRecordingContainerView<Factory: ViewFactory>: View {

    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.utils) var utils
    
    let factory: Factory
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?
    
    @StateObject var handler = VoiceRecordingHandler()
    @State var playingIndex: Int?
    
    private var player: AudioPlaying {
        utils.audioPlayer
    }
    
    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            if let quotedMessage = message.quotedMessage {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }
            
            ForEach(message.voiceRecordingAttachments, id: \.self) { attachment in
                CustomVoiceRecordingView(
                    handler: handler,
                    addedVoiceRecording: AddedVoiceRecording(
                        url: attachment.payload.voiceRecordingURL,
                        duration: attachment.payload.duration ?? 0,
                        waveform: attachment.payload.waveformData ?? []
                    ),
                    index: index(for: attachment),
                    foregroundStyleDark: !message.isRightAligned
                    
                )
            }
            
            if !message.text.isEmpty {
                CustomAttachmentTextView(message: message)
            }
        }
        .onReceive(handler.$context, perform: { value in
            guard message.voiceRecordingAttachments.count > 1 else { return }
            if value.state == .playing {
                let index = message.voiceRecordingAttachments.firstIndex { payload in
                    payload.voiceRecordingURL == value.assetLocation
                }
                if index != playingIndex {
                    playingIndex = index
                }
            } else if value.state == .stopped, let playingIndex {
                if playingIndex < (message.voiceRecordingAttachments.count - 1) {
                    let next = playingIndex + 1
                    let nextURL = message.voiceRecordingAttachments[next].voiceRecordingURL
                    player.loadAsset(from: nextURL)
                }
                self.playingIndex = nil
            }
        })
        .onAppear {
            player.subscribe(handler)
        }
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(message: message, isFirst: isFirst, cornerRadius: 14)
            )
        )
    }
    
    private func index(for attachment: ChatMessageVoiceRecordingAttachment) -> Int {
        message.voiceRecordingAttachments.firstIndex(of: attachment) ?? 0
    }
}

struct CustomVoiceRecordingView: View {
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts
    
    @State var isPlaying: Bool = false
    @State var loading: Bool = false
    @State var rate: AudioPlaybackRate = .normal
    @ObservedObject var handler: VoiceRecordingHandler
    
    let addedVoiceRecording: AddedVoiceRecording
    let index: Int
    let foregroundStyleDark: Bool
    
    private var player: AudioPlaying {
        utils.audioPlayer
    }
    
    private var rateTitle: String {
        switch rate {
        case .half:
            return "x0.5"
        default:
            return "x\(Int(rate.rawValue))"
        }
    }
    
    private var duration: String {
        utils.videoDurationFormatter.format(showContextDuration ? handler.context.currentTime : addedVoiceRecording.duration) ?? ""
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                Button(action: {
                    handlePlayTap()
                }, label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(foregroundStyleDark ? Color(colors.text) : Color.white)
                        .frame(width: 28, height: 28)
                })
                    .opacity(loading ? 0 : 1)
                    .overlay(
                        loading ?
                             ProgressView()
                                 .progressViewStyle(CircularProgressViewStyle(tint: foregroundStyleDark ? Color("Purple") : Color.white))
                             : nil
                    )
                
                Text(duration)
                    .font(fonts.caption2)
                    .foregroundStyle(foregroundStyleDark ? Color(colors.textLowEmphasis) : Color.white)
                    .opacity(0.5)
                    .frame(width: 34)
                    .multilineTextAlignment(.center)
            }
            
            CustomWaveformViewSwiftUI(
                audioContext: handler.context,
                addedVoiceRecording: addedVoiceRecording,
                foregroundStyleDark: foregroundStyleDark,
                onSliderChanged: { timeInterval in
                    if isCurrentRecordingActive {
                        player.seek(to: timeInterval)
                    } else {
                        player.loadAsset(from: addedVoiceRecording.url)
                        player.seek(to: timeInterval)
                    }
                },
                onSliderTapped: {
                    handlePlayTap()
                }
            )
            .frame(height: 30)
                        
            Button(action: {
                if rate == .normal {
                    rate = .double
                } else if rate == .double {
                    rate = .half
                } else {
                    rate = .normal
                }
                player.updateRate(rate)
            }, label: {
                Text(rateTitle)
                    .font(fonts.footnote)
                    .foregroundColor(foregroundStyleDark ? Color(colors.textLowEmphasis) : Color.white)
            })
            .frame(width: 28)
            .opacity(isPlaying ? 1 : 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .onReceive(handler.$context, perform: { value in
            guard value.assetLocation == addedVoiceRecording.url else { return }
            if value.state == .loading {
                loading = true
                return
            } else if loading {
                loading = false
            }
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        })
    }
    
    private var showContextDuration: Bool {
        isCurrentRecordingActive && handler.context.currentTime > 0
    }
    
    private var isCurrentRecordingActive: Bool {
        handler.context.assetLocation == addedVoiceRecording.url
    }
    
    private func handlePlayTap() {
        if isPlaying {
            player.pause()
        } else {
            player.loadAsset(from: addedVoiceRecording.url)
        }
    }
}
