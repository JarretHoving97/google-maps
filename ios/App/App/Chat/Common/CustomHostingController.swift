//
//  CustomHostingController.swift
//  App
//
//  Created by Jarret on 16/01/2025.
//

import SwiftUI

class CustomHostingController<Content: View>: UIHostingController<Content> {

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        if parent == nil {
            ExtendedStreamPlugin.shared.notifyNavigateBackToListeners(dismiss: false)
        }
    }
}
