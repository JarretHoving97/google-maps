import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomPinnedMessage: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) var fonts
    @Injected(\.chatClient) var chatClient

    @State private var isEditModalPresented = false
    @State private var updatedPinnedMessage: String?
    @State private var displayedText: AttributedString?

    private let channel: ChatChannel

    public init(channel: ChatChannel) {
        self.channel = channel
    }

    var isUpdateable: Bool {
        if !channel.canUpdateChannel {
            return false
        }

        return channel.membership?.memberRole == MemberRole.coOrganizer || channel.isCurrentUserOrganizer
    }

    var pinnedMessage: String? {
        if let updatedPinnedMessage {
            return updatedPinnedMessage
        }

        if let pinnedMessage = channel.extraData["pinnedMessage"]?.stringValue {
            return pinnedMessage
        }

        return nil
    }

    var subtitle: String? {
        if let pinnedMessage, !pinnedMessage.isEmpty {
            return pinnedMessage
        }

        if isUpdateable {
            return tr("custom.pinnedMessage.subtitle")
        }

        return nil
    }

    func showEditPinnedMessageSheet() {
        if isUpdateable {
            isEditModalPresented.toggle()
        }
    }

    func detectLinks() {
        if let subtitle {
            displayedText = linkify(for: subtitle, attributes: [
                .foregroundColor: Color.white.opacity(0.8),
                .font: fonts.caption1
            ])
        }
    }

    var body: some View {
        if let subtitle {
            ZStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 6) {
                        Image("Pin")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(maxWidth: 8, maxHeight: 12)

                        Text("custom.pinnedMessage.title")
                            .font(fonts.caption1.bold())
                            .foregroundColor(.white)
                    }

                    Group {
                        if let displayedText {
                            Text(displayedText)
                        } else {
                            Text(subtitle)
                        }
                    }
                    .font(fonts.caption1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.white.opacity(0.8))
                    .tint(Color.white)
                    .lineLimit(3)
                    .padding(0)
                }
                .onAppear {
                    detectLinks()
                }
                .onChange(of: subtitle) { _ in
                    detectLinks()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("Orange"))
                .cornerRadius(12)
                .modifier(ShadowModifier())
                .padding(.all, 12)
                .onTapGesture(perform: showEditPinnedMessageSheet)
            }
            .chatSheetPresentation(
                isPresented: $isEditModalPresented,
                detents: [.medium()]
            ) {
                CustomEditPinnedMessageSheetView(
                    isPresented: $isEditModalPresented,
                    channel: channel,
                    pinnedMessage: pinnedMessage,
                    updatedPinnedMessage: $updatedPinnedMessage
                )
            }
        }
    }
}

struct CustomEditPinnedMessageSheetView: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) var fonts
    @Injected(\.chatClient) var chatClient

    private let channel: ChatChannel
    private let pinnedMessage: String?

    @Binding var isPresented: Bool
    @Binding private var updatedPinnedMessage: String?

    @State private var newPinnedMessage: String = ""

    public init(
        isPresented: Binding<Bool>,
        channel: ChatChannel,
        pinnedMessage: String?,
        updatedPinnedMessage: Binding<String?>
    ) {
        _isPresented = isPresented
        self.channel = channel
        self.pinnedMessage = pinnedMessage
        _updatedPinnedMessage = updatedPinnedMessage

        if let pinnedMessage = pinnedMessage {
            _newPinnedMessage = State(initialValue: pinnedMessage)
        }
    }

    func updatePinnedMessage() {
        let channel = chatClient.channelController(for: channel.cid)

        // Note: only overrides keys of `extraData` specified.
        channel.partialChannelUpdate(
            extraData: ["pinnedMessage": RawJSON(stringLiteral: newPinnedMessage)]
        )

        // @TODO: Figure out a way to refetch the channel instead of using the `updatedPinnedMessage`.

        updatedPinnedMessage = newPinnedMessage
        isPresented = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("custom.pinnedMessage.title")
                    .font(fonts.title)

                Text("custom.pinnedMessage.subtitle")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(fonts.body)
            }

            AmiTextAreaFieldView(value: $newPinnedMessage, maxChars: 125)
                .frame(maxWidth: .infinity, maxHeight: 135)

            Spacer()

            AmiButton("custom.save", action: updatePinnedMessage)
        }
        .padding(.all, 16)
        .padding(.top, 24)
    }
}
