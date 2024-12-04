import SwiftUI
import StreamChatSwiftUI

struct AmiTextAreaFieldView: View {
    @Injected(\.fonts) var fonts

    @Binding var value: String

    @State var typedChars: Int

    var maxChars: Int?

    init(value: Binding<String>, maxChars: Int? = nil) {
        _value = value
        _typedChars = State(initialValue: value.wrappedValue.count)
        self.maxChars = maxChars
    }

    @FocusState private var focusing: Bool

    var body: some View {
        VStack(spacing: 4) {
            if let maxChars {
                HStack(spacing: 0) {
                    Spacer()

                    Text("\(typedChars) / \(maxChars)")
                        .foregroundColor(Color("Grey"))
                        .font(fonts.caption2)
                }
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $value)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.white)
                    .cornerRadius(8)
                    .focused($focusing)
                    .font(fonts.body)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focusing ? Color("Purple") : Color("Grey Light"), lineWidth: 2)
                    )
                    .onChange(of: value) { _ in
                        if let maxChars {
                            typedChars = value.count
                            value = String(value.prefix(maxChars))
                        }
                    }

                if value.isEmpty {
                    Text("custom.input.textarea.placeholder")
                        .font(fonts.body)
                        .foregroundColor(Color("Grey Light"))
                        .padding(16)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
