import SwiftUI
import StreamChatSwiftUI

struct AmiRadioButton: View {
    @Injected(\.fonts) var fonts

    @Binding var isSelected: Bool

    let label: LocalizedStringKey

    // Default initalizer
    init(isSelected: Binding<Bool>, label: LocalizedStringKey) {
      self._isSelected = isSelected
      self.label = label
    }

   // Multiple options initalizer
    init<V: Hashable>(tag: V, selection: Binding<V?>, label: LocalizedStringKey) {
      self._isSelected = Binding(
        get: { selection.wrappedValue == tag },
        set: { _ in selection.wrappedValue = tag }
      )
      self.label = label
    }

    var body: some View {
        HStack(spacing: 10) {
            circleView

            labelView.font(fonts.caption1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSelected = true
            }
        }
    }
}

private extension AmiRadioButton {

    var outlineColor: Color {
        isSelected ? Color("Purple") : Color("Grey Light")
    }

    @ViewBuilder var labelView: some View {
        Text(label)
    }

    @ViewBuilder var circleView: some View {
        Circle()
            .fill(Color.white)
            .padding(4)
            .overlay(
                Circle()
                    .strokeBorder(outlineColor, lineWidth: isSelected ? 8 : 2)
                    .transition(.fade)
            )
            .frame(width: 24, height: 24)
    }
}
