import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomEmptyMessagesView: View {

    @Injected(\.fonts) var fonts

    public let channel: ChatChannel

    @State private var isSafetyCheckInfoSheetPresented = false

    var directNotice: some View {
        Group {
            if !channel.isSupportChatChannel {
                VStack(spacing: 8) {
                    HStack {
                        AmiSafetyCheckIcon(variant: .outLined, renderingMode: .template)
                            .foregroundColor(Color("Grey"))
                            .frame(width: 16, height: 16)
                    }
                    .frame(width: 32, height: 32)
                    .background(Color("Grey Light"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("custom.channel.emptyState.direct")
                        .font(fonts.footnote)
                        .foregroundColor(Color("Grey"))
                        .multilineTextAlignment(.center)
                }
                .onTapGesture {
                    isSafetyCheckInfoSheetPresented = true
                }
                .chatSheetPresentation(
                    isPresented: $isSafetyCheckInfoSheetPresented,
                    detents: [.medium()]
                ) {
                    CustomSafetyCheckInfoSheetView(
                        isPresented: $isSafetyCheckInfoSheetPresented,
                        channel: channel,
                        variant: SafetyCheckInfoVariant.Receiver
                    )
                }
            } else {
                EmptyView()
            }
        }
    }

    var groupNotice: some View {
        Text("custom.channel.emptyState.group")
            .font(fonts.footnote)
            .foregroundColor(Color("Grey"))
            .multilineTextAlignment(.center)
    }

    var body: some View {
        ZStack {
            if channel.isDirectMessageChannel {
                directNotice
            } else {
                groupNotice
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.all, 32)
        .background(Color("Pale"))
        .accessibilityIdentifier("EmptyMessagesView")
    }
}
