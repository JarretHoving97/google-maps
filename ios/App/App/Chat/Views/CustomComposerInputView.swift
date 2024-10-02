import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct TextSizeConstants {
    static let composerConfig = InjectedValues[\.utils].composerConfig
    static let defaultInputViewHeight: CGFloat = 38.0
    static var minimumHeight: CGFloat {
        composerConfig.inputViewMinHeight
    }

    static var maximumHeight: CGFloat {
        composerConfig.inputViewMaxHeight
    }

    static var minThreshold: CGFloat {
        composerConfig.inputViewMinHeight
    }

    static var cornerRadius: CGFloat {
        composerConfig.inputViewCornerRadius
    }
}

/// View for the composer's input (text and media).
public struct CustomComposerInputView<Factory: ViewFactory>: View, KeyboardReadable {

    @EnvironmentObject var viewModel: MessageComposerViewModel
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils

    var factory: Factory
    @Binding var text: String
    @Binding var selectedRangeLocation: Int
    @Binding var command: ComposerCommand?
    var addedAssets: [AddedAsset]
    var addedFileURLs: [URL]
    var addedCustomAttachments: [CustomAttachment]
    @Binding var quotedMessage: ChatMessage?
    var maxMessageLength: Int?
    var cooldownDuration: Int
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    var removeAttachmentWithId: (String) -> Void

    @State var textHeight: CGFloat = TextSizeConstants.minimumHeight
    @State var keyboardShown = false

    public init(
        factory: Factory,
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int? = nil,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        removeAttachmentWithId: @escaping (String) -> Void
    ) {
        self.factory = factory
        _text = text
        _selectedRangeLocation = selectedRangeLocation
        _command = command
        self.addedAssets = addedAssets
        self.addedFileURLs = addedFileURLs
        self.addedCustomAttachments = addedCustomAttachments
        _quotedMessage = quotedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.removeAttachmentWithId = removeAttachmentWithId
    }

    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = TextSizeConstants.minimumHeight
        let maxHeight: CGFloat = TextSizeConstants.maximumHeight

        if textHeight < minHeight {
            return minHeight
        }

        if textHeight > maxHeight {
            return maxHeight
        }

        return textHeight
    }
    
    var inputPaddingsConfig: PaddingsConfig {
        utils.composerConfig.inputPaddingsConfig
    }
    
    func removeQuotedMessage() {
        quotedMessage = nil
    }

    public var body: some View {
        VStack(spacing: 2) {
            if let quotedMessage = quotedMessage {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: true,
                    isInComposer: true,
                    scrolledId: .constant(nil)
                )
                .overlay(alignment: .topTrailing) {
                    Button(action: removeQuotedMessage) {
                        Image(systemName: "multiply")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 6, height: 6)
                            .foregroundColor(Color.white)
                    }
                    .frame(width: 14, height: 14)
                    .background(Color("Red"))
                    .clipShape(Circle())
                }
            }

            if !addedAssets.isEmpty {
                AddedImageAttachmentsView(
                    images: addedAssets,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .transition(.scale)
                .animation(.default)
            }

            if !addedFileURLs.isEmpty {
                if !addedAssets.isEmpty {
                    Divider()
                }

                AddedFileAttachmentsView(
                    addedFileURLs: addedFileURLs,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .padding(.trailing, 8)
            }
            
            if !viewModel.addedVoiceRecordings.isEmpty {
                CustomAddedVoiceRecordingsView(
                    addedVoiceRecordings: viewModel.addedVoiceRecordings,
                    onDiscardAttachment: removeAttachmentWithId
                )
                .padding(.trailing, 8)
                .padding(.top, 8)
            }

            if !addedCustomAttachments.isEmpty {
                factory.makeCustomAttachmentPreviewView(
                    addedCustomAttachments: addedCustomAttachments,
                    onCustomAttachmentTap: onCustomAttachmentTap
                )
            }

            HStack {
                if let command = command,
                   let displayInfo = command.displayInfo,
                   displayInfo.isInstant == true {
                    HStack(spacing: 0) {
                        Image(uiImage: images.smallBolt)
                        Text(displayInfo.displayName.uppercased())
                    }
                    .padding(.horizontal, 8)
                    .font(fonts.footnoteBold)
                    .frame(height: 24)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                
                factory.makeComposerTextInputView(
                    text: $text,
                    height: $textHeight,
                    selectedRangeLocation: $selectedRangeLocation,
                    placeholder: isInCooldown ? tr("composer.placeholder.slowMode") : tr("composer.placeholder.message"),
                    editable: !isInCooldown,
                    maxMessageLength: maxMessageLength,
                    currentHeight: textFieldHeight
                )
                .accessibilityIdentifier("ComposerTextInputView")
                .accessibilityElement(children: .contain)
                .frame(height: textFieldHeight)
                .overlay(
                    command?.displayInfo?.isInstant == true ?
                        HStack {
                            Spacer()
                            Button {
                                self.command = nil
                            } label: {
                                DiscardButtonView(
                                    color: Color(colors.background7)
                                )
                            }
                        }
                        : nil
                )
            }
            .frame(height: textFieldHeight)
        }
        .padding(.top, inputPaddingsConfig.top)
        .padding(.leading, inputPaddingsConfig.leading)
        .padding(.trailing, inputPaddingsConfig.trailing)
        .padding(.bottom, inputPaddingsConfig.bottom)
        .background(composerInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
                .stroke(Color(keyboardShown ? highlightedBorder : colors.innerBorder))
        )
        .clipShape(
            RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
        )
        .onReceive(keyboardWillChangePublisher) { visible in
            keyboardShown = visible
        }
        .accessibilityIdentifier("ComposerInputView")
    }

    private var composerInputBackground: Color {
        var colors = colors
        return Color(colors.composerInputBackground)
    }
    
    private var highlightedBorder: UIColor {
        var colors = colors
        return colors.composerInputHighlightedBorder
    }

    private var shouldAddVerticalPadding: Bool {
        !addedFileURLs.isEmpty || !addedAssets.isEmpty
    }

    private var isInCooldown: Bool {
        cooldownDuration > 0
    }
}

public struct CustomComposerInputContainerView<Factory: ViewFactory>: View {
    public init(
        factory: Factory,
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int? = nil,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        removeAttachmentWithId: @escaping (String) -> Void,
        shouldScroll: Bool
    ) {
        self.factory = factory
        _text = text
        _selectedRangeLocation = selectedRangeLocation
        _command = command
        self.addedAssets = addedAssets
        self.addedFileURLs = addedFileURLs
        self.addedCustomAttachments = addedCustomAttachments
        self.quotedMessage = quotedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.removeAttachmentWithId = removeAttachmentWithId
        self.shouldScroll = shouldScroll
    }
    
    var factory: Factory
    @Binding var text: String
    @Binding var selectedRangeLocation: Int
    @Binding var command: ComposerCommand?
    var addedAssets: [AddedAsset]
    var addedFileURLs: [URL]
    var addedCustomAttachments: [CustomAttachment]
    var quotedMessage: Binding<ChatMessage?>
    var maxMessageLength: Int?
    var cooldownDuration: Int
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    var removeAttachmentWithId: (String) -> Void
    var shouldScroll: Bool
    
    public var body: some View {
        Spacer()
        
        if shouldScroll {
            ScrollView {
                CustomComposerInputView(
                    factory: factory,
                    text: $text,
                    selectedRangeLocation: $selectedRangeLocation,
                    command: $command,
                    addedAssets: addedAssets,
                    addedFileURLs: addedFileURLs,
                    addedCustomAttachments: addedCustomAttachments,
                    quotedMessage: quotedMessage,
                    maxMessageLength: maxMessageLength,
                    cooldownDuration: cooldownDuration,
                    onCustomAttachmentTap: onCustomAttachmentTap,
                    removeAttachmentWithId: removeAttachmentWithId
                )
            }
            .frame(height: 240)
        } else {
            CustomComposerInputView(
                factory: factory,
                text: $text,
                selectedRangeLocation: $selectedRangeLocation,
                command: $command,
                addedAssets: addedAssets,
                addedFileURLs: addedFileURLs,
                addedCustomAttachments: addedCustomAttachments,
                quotedMessage: quotedMessage,
                maxMessageLength: maxMessageLength,
                cooldownDuration: cooldownDuration,
                onCustomAttachmentTap: onCustomAttachmentTap,
                removeAttachmentWithId: removeAttachmentWithId
            )
        }
    }
}
