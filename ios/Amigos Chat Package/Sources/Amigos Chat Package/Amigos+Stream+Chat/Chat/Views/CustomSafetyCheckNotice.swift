// swiftlint:disable all
import SwiftUI
import StreamChat
import StreamChatSwiftUI

public enum SafetyCheckState: String {
    case Unanswered = "UNANSWERED"
    case Positive = "POSITIVE"
    case Negative = "NEGATIVE"
}

public enum SafetyCheckReason: String {
  case Other = "OTHER"
  case Commercial = "COMMERICAL"
  case Dating = "DATING"
  case InappropriateLanguage = "INAPPROPRIATE_LANGUAGE"
  case Spam = "SPAM"
}

struct CustomSafetyCheckNotice: View {

    @Injected(\.chatClient) var chatClient
    @Injected(\.fonts) private var fonts

    let channel: ChatChannel

    @State private var isNegativeSafetyCheckSheetPresented = false
    @State private var isSafetyCheckInfoSheetPresented = false
    @State private var updatedSafetyCheckState: SafetyCheckState?

    public init(channel: ChatChannel) {
        self.channel = channel
    }

    var safetyCheckState: SafetyCheckState? {
        if let updatedSafetyCheckState {
            return updatedSafetyCheckState
        }

        if let stringValue = channel.extraData["safetyCheckState"]?.stringValue {
            if let safetyCheck = SafetyCheckState(rawValue: stringValue) {
                return safetyCheck
            }
        }

        return nil
    }

    var currentUserId: String {
        chatClient.currentUserId ?? ""
    }

    var isCreatedByCurrentUserId: Bool {
        let createdByUserId = channel.createdBy?.id

        guard let createdByUserId else {
            return false
        }

        return currentUserId == createdByUserId
    }

    func updateChannel(_ safetyCheckState: SafetyCheckState, _ safetyCheckReason: SafetyCheckReason? = nil) {
        guard let otherUserId = channel.otherUser?.id else {
            return
        }

        executeGraphQLRequest(
            body: getRequestBody(userId: otherUserId, state: safetyCheckState, reason: safetyCheckReason)
        ) { result  in
            switch result {
            case .success:
                // @TODO: Figure out a way to refetch the channel instead of using the `updatedSafetyCheckState`.
                updatedSafetyCheckState = safetyCheckState
            case .failure(let error):
                print("Something went wrong when updating safety check.", error)
            }
        }
    }

    var showSafetyCheckNotice: Bool {
        channel.otherUser != nil &&
        !channel.isSupportChatChannel &&
        !isCreatedByCurrentUserId &&
        safetyCheckState == .Unanswered
    }

    var body: some View {
        if showSafetyCheckNotice {
            HStack(spacing: 12) {
                HStack {
                    AmiSafetyCheckIcon()
                        .frame(width: 16, height: 16)
                }
                .frame(width: 32, height: 32)
                .background(Color("Purple"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture {
                    isSafetyCheckInfoSheetPresented = true
                }

                if let name = channel.otherUser?.name {
                    Text(tr("custom.safetyCheck.notice.title", name))
                        .font(fonts.caption2)
                }

                Spacer()
                    .layoutPriority(-1)

                HStack(spacing: 8) {
                    AmiThumbButton(positive: false) {
                        isNegativeSafetyCheckSheetPresented = true
                    }

                    AmiThumbButton(positive: true) {
                        updateChannel(.Positive)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .modifier(ShadowModifier())
            .padding(.all, 12)

            // 2 sheet modifiers seems to behave weird sometimes.

            Text("").hidden().chatSheetPresentation(
                isPresented: $isNegativeSafetyCheckSheetPresented,
                detents: [.medium()]
            ) {
                CustomNegativeSafetyCheckSheetView(
                    isPresented: $isNegativeSafetyCheckSheetPresented,
                    updatedSafetyCheckState: $updatedSafetyCheckState,
                    updateChannel: updateChannel
                )
            }

            Text("").hidden().chatSheetPresentation(
                isPresented: $isSafetyCheckInfoSheetPresented,
                detents: [.medium()]
            ) {
                CustomSafetyCheckInfoSheetView(
                    isPresented: $isSafetyCheckInfoSheetPresented,
                    channel: channel,
                    variant: SafetyCheckInfoVariant.Sender
                )
            }
        }
    }
}

struct CustomNegativeSafetyCheckSheetView: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) var fonts
    @Injected(\.chatClient) var chatClient

    let updateChannel: (SafetyCheckState, SafetyCheckReason?) -> Void

    @Binding var isPresented: Bool
    @Binding var updatedSafetyCheckState: SafetyCheckState?
    @State var selectedSafetyCheckReason: SafetyCheckReason?

    init(
        isPresented: Binding<Bool>,
        updatedSafetyCheckState: Binding<SafetyCheckState?>,
        updateChannel: @escaping (SafetyCheckState, SafetyCheckReason?) -> Void
    ) {
        _isPresented = isPresented
        _updatedSafetyCheckState = updatedSafetyCheckState
        self.updateChannel = updateChannel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("custom.safetyCheck.review.sheet.title")
                    .font(fonts.title)

                Text("custom.safetyCheck.review.sheet.subtitle")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(fonts.body)

                VStack(alignment: .leading, spacing: 12) {
                    AmiRadioButton(tag: .Commercial, selection: $selectedSafetyCheckReason, label: "custom.safetyCheck.review.sheet.option.commercial")
                    AmiRadioButton(tag: .Dating, selection: $selectedSafetyCheckReason, label: "custom.safetyCheck.review.sheet.option.dating")
                    AmiRadioButton(tag: .InappropriateLanguage, selection: $selectedSafetyCheckReason, label: "custom.safetyCheck.review.sheet.option.inappropriateLanguage")
                    AmiRadioButton(tag: .Spam, selection: $selectedSafetyCheckReason, label: "custom.safetyCheck.review.sheet.option.spam")
                    AmiRadioButton(tag: .Other, selection: $selectedSafetyCheckReason, label: "custom.safetyCheck.review.sheet.option.other")
                }
                .padding(.top, 16)
            }

            Spacer()

            AmiButton(
                "custom.save",
                disabled: selectedSafetyCheckReason == nil
            ) {
                updateChannel(.Negative, $selectedSafetyCheckReason.wrappedValue)
            }
        }
        .padding(.all, 16)
        .padding(.top, 24)
    }
}
