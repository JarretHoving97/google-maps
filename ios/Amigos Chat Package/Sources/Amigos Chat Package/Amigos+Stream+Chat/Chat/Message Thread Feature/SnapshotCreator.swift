import SwiftUI
import UIKit
import StreamChatSwiftUI

public protocol SnapshotCreator {
    func makeSnapshot(for view: AnyView) -> UIImage
}

public extension SnapshotCreator {
    func topVC() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
}

private extension UIViewController {

    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}

/// Default implementation of the `SnapshotCreator`.
public class DefaultSnapshotCreator: SnapshotCreator {

    @Injected(\.images) var images

    public init() { /* Public init. */ }

    public func makeSnapshot(for view: AnyView) -> UIImage {
        guard let uiView: UIView = topVC()?.view else {
            return images.snapshot
        }
        return makeSnapshot(from: uiView)
    }

    func makeSnapshot(from view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
