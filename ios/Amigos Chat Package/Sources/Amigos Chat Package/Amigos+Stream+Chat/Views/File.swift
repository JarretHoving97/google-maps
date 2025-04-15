//
//  MediumDetentSheetModifier.swift
//
//
//  Created by Jarret on 07/04/2025.
//

import SwiftUI

struct MediumDetentSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                if #available(iOS 16.0, *) {
                    self.sheetContent()
                        .presentationDetents([.medium])
                } else {
                    self.sheetContent()
                }
            }
    }
}

extension View {

    func mediumDetentSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(
            MediumDetentSheetModifier(
                isPresented: isPresented,
                sheetContent: content
            )
        )
    }
}
