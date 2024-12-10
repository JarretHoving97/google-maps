//
//  HidesKeyboardAndAttachmentsOnTapGesture.swift
//  App
//
//  Created by Jarret on 09/12/2024.
//

import SwiftUI
import UIKit

/// View modifier for hiding the keyboard on tap.
private struct HidesKeyboardAndAttachmentOnTapGesture: ViewModifier {
    @Environment(\.attachmentController) var attachmentController

    public init() {}

    public func body(content: Content) -> some View {
        content
            .gesture(TapGesture().onEnded { _ in
                resignFirstResponder()
                attachmentController.onCloseAttachmentView?()
            }
        )
    }

    // hide keyboard
    private func resignFirstResponder() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension View {

    func dismissKeyboardAndAttachmentViewOnTap() -> some View {
        modifier(HidesKeyboardAndAttachmentOnTapGesture())
    }
}
