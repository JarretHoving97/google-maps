import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// View for picking the source of the attachment (photo, files or camera).
public struct CustomAttachmentSourcePickerView: View {

    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    var selected: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void

    public init(
        selected: AttachmentPickerState,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.selected = selected
        self.onTap = onTap
    }

    public var body: some View {

        HStack(alignment: .center, spacing: 24) {
            AttachmentPickerButton(
                icon: images.attachmentPickerPhotos,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerPhotos")

//            Files are disabled.
//            AttachmentPickerButton(
//                icon: images.attachmentPickerFolder,
//                pickerType: .files,
//                isSelected: selected == .files,
//                onTap: onTap
//            )
//            .accessibilityIdentifier("attachmentPickerFiles")

            AttachmentPickerButton(
                icon: images.attachmentPickerCamera,
                pickerType: .camera,
                isSelected: selected == .camera,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerCamera")

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(colors.background1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentSourcePickerView")
    }
}
