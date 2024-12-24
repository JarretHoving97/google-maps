import StreamChat
import SwiftUI
import StreamChatSwiftUI

/// View for picking the attachment type (media or giphy commands).
public struct CustomAttachmentPickerTypeView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Environment(\.attachmentController) var attachmentController
    @Binding var pickerTypeState: PickerTypeState
    var channelConfig: ChannelConfig?

    public init(
        pickerTypeState: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?
    ) {
        _pickerTypeState = pickerTypeState
        self.channelConfig = channelConfig
    }

    var state: AttachmentPickerType {
        switch pickerTypeState {
        case .collapsed:
            return AttachmentPickerType.none
        case let .expanded(attachmentPickerType):
            return attachmentPickerType
        }
    }

    public var body: some View {
        HStack(spacing: 16) {
            if channelConfig?.uploadsEnabled == true {
                CustomPickerTypeButton(
                    pickerTypeState: $pickerTypeState,
                    pickerType: .media,
                    selected: state
                )
                .accessibilityIdentifier("PickerTypeButtonMedia")
            }
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 12)
        .accessibilityElement(children: .contain)
        .onAppear(perform: setupAttachmentControllerCallback)
    }

    private func setupAttachmentControllerCallback() {
        attachmentController.onCloseAttachmentView = {
            withAnimation {
                pickerTypeState = .expanded(.none)
            }
        }
    }
}

/// View for the picker type button.
struct CustomPickerTypeButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    @Binding var pickerTypeState: PickerTypeState

    let pickerType: AttachmentPickerType
    let selected: AttachmentPickerType

    @State private var showPaperclip: Bool = true

    var body: some View {
        Button {
            withAnimation {
                onTap(attachmentType: pickerType, selected: selected)
            }
        } label: {
            Image(systemName: !showPaperclip ? "xmark.circle.fill" : "paperclip")
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(height: 16)
                .foregroundColor(
                    showPaperclip ? Color(colors.textLowEmphasis) :  Color("Purple")
                )
        }

        .onChange(of: pickerTypeState) { value in

            /// .collapsed is an unused state for our custom implementation which we can't access
            /// so we need to check on it.
            guard value != .collapsed else { return }

            if value == .expanded(.none) {
                showPaperclip = true
            } else {
                showPaperclip = pickerType == selected
            }
        }

    }

    private func onTap(
        attachmentType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) {
        /// also here (see previous comment)
        if selected == attachmentType || pickerTypeState == .collapsed {
            pickerTypeState = .expanded(.none)
        } else {
            pickerTypeState = .expanded(attachmentType)
        }
    }
}
