import StreamChat
import SwiftUI
import StreamChatSwiftUI

/// View for picking the attachment type (media or giphy commands).
public struct CustomAttachmentPickerTypeView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

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
    }
}

/// View for the picker type button.
struct CustomPickerTypeButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    @Binding var pickerTypeState: PickerTypeState

    let pickerType: AttachmentPickerType
    let selected: AttachmentPickerType

    var body: some View {
        Button {
            withAnimation {
                onTap(attachmentType: pickerType, selected: selected)
            }
        } label: {
            Image(systemName: "paperclip")
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(height: 16)
                .foregroundColor(
                    foregroundColor(for: pickerType, selected: selected)
                )
        }
    }

//    private var icon: UIImage {
//        if pickerType == .media {
//            return images.openAttachments
//        } else {
//            return images.commands
//        }
//    }

    private func onTap(
        attachmentType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) {
        if selected == attachmentType {
            pickerTypeState = .expanded(.none)
        } else {
            pickerTypeState = .expanded(attachmentType)
        }
    }

    private func foregroundColor(
        for pickerType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) -> Color {
        if pickerType == selected {
            return Color("Purple")
        } else {
            return Color(colors.textLowEmphasis)
        }
    }
}
