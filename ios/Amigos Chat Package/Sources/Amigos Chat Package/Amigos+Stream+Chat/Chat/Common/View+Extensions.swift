import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Method for making a haptic feedback.
    /// - Parameter style: feedback style
    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func flippedUpsideDown() -> some View {
        modifier(FlippedUpsideDown())
    }

    func chatSheetPresentation<Content>(
         isPresented: Binding<Bool>,
         detents: [UISheetPresentationController.Detent],
         content: () -> Content
    ) -> some View where Content: View {
         modifier(
             CustomSheetViewModifier(
                 isPresented: isPresented,
                 detents: detents,
                 sheetContent: content
             )
         )
     }
}
