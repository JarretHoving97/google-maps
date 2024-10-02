import StreamChatSwiftUI
import SwiftUI
import StreamChat

enum SafetyCheckInfoVariant: String {
    case Receiver = "receiver"
    case Sender = "sender"
}

private struct Content {
    let subtitle: String
    let examples: [Example]
}

private struct Example: Identifiable {
    let id = UUID()
    let title: String
    let positive: Bool
}

struct CustomSafetyCheckInfoSheetView: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.fonts) var fonts

    let channel: ChatChannel
    let variant: SafetyCheckInfoVariant

    @Binding var isPresented: Bool
    
    init(
        isPresented: Binding<Bool>,
        channel: ChatChannel,
        variant: SafetyCheckInfoVariant
    ) {
        _isPresented = isPresented
        self.channel = channel
        self.variant = variant
    }
    
    private var otherUserName: String {
        channel.otherUser?.name ?? ""
    }
    
    private var content: Content {
        if variant == .Receiver {
            return .init(
                subtitle: tr("custom.safetyCheck.info.sheet.receiver.subtitle"),
                examples: [
                    .init(title: tr("custom.safetyCheck.info.sheet.receiver.examples.join"), positive: true),
                    .init(title: tr("custom.safetyCheck.info.sheet.receiver.examples.host"), positive: true),
                    .init(title: tr("custom.safetyCheck.info.sheet.receiver.examples.other"), positive: false),
                ]
            )
        } else {
            return .init(
                subtitle: tr("custom.safetyCheck.info.sheet.sender.subtitle", otherUserName, otherUserName),
                examples: [
                    .init(title: tr("custom.safetyCheck.info.sheet.sender.examples.join"), positive: true),
                    .init(title: tr("custom.safetyCheck.info.sheet.sender.examples.host"), positive: true)
                ]
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("custom.safetyCheck.info.sheet.title")
                    .font(fonts.title)
                
                Text(content.subtitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(fonts.body)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(content.examples) { example in
                    HStack(spacing: 12) {
                        Image(example.positive ? "Check" : "Cross")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(example.positive ? Color("Green") : Color("Red"))

                        Text(example.title)
                            .font(fonts.caption1)
                        
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color("Grey Light"))
            .cornerRadius(12)
            
            Spacer()
            
            AmiButton("custom.iUnderstand") {
                isPresented = false
            }
        }
        .padding(.all, 16)
        .padding(.top, 24)
    }
}
