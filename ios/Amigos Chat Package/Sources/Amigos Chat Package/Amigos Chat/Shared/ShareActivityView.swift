//
//  Untitled.swift
//  Amigos Chat Package
//
//  Created by Jarret on 31/01/2025.
//

import SwiftUI
/// View controller reprensetable which wraps up the activity view controller.
struct ShareActivityView: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ShareActivityView>
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.popoverPresentationController?.sourceView = UIApplication.shared.windows.first?.rootViewController?.view

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ShareActivityView>
    ) { /* Not needed. */ }
}
