//
//  CustomHostController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 17/01/2025.
//

import SwiftUI
import UIKit

/// has a `onWillMoveToParent` call back to perform actions
/// whenever the view navigates to an other screen
/// completes with an optional `UIViewController` which is the parent controller
/// If is nil the view is popped. If it's not nil the view will be pushed.
class CustomHostingController<Content: View>: UIHostingController<Content> {
    var onWillMoveToParent: ((UIViewController?) -> Void)?

    override init(rootView: Content) {
        super.init(rootView: rootView)
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        onWillMoveToParent?(parent)
    }
}
