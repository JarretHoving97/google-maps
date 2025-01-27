import SwiftUI

extension UIView {
    var withoutAutoresizingMaskConstraints: Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    func withAccessibilityIdentifier(identifier: String) -> Self {
        accessibilityIdentifier = identifier
        return self
    }

    func embed(_ subview: UIView, insets: NSDirectionalEdgeInsets = .zero) {
        addSubview(subview)

        NSLayoutConstraint.activate([
            subview.leadingAnchor.pin(equalTo: leadingAnchor, constant: insets.leading),
            subview.trailingAnchor.pin(equalTo: trailingAnchor, constant: -insets.trailing),
            subview.topAnchor.pin(equalTo: topAnchor, constant: insets.top),
            subview.bottomAnchor.pin(equalTo: bottomAnchor, constant: -insets.bottom)
        ])
    }
}

extension NSLayoutConstraint {
    /// Changes the priority of `self` to the provided one.
    /// - Parameter priority: The priority to be applied.
    /// - Returns: `self` with updated `priority`.
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    /// Returns updated `self` with `priority == .streamAlmostRequire`
    var almostRequired: NSLayoutConstraint {
        with(priority: .defaultHigh)
    }
}

extension NSLayoutAnchor {
    // These methods return an inactive constraint of the form thisAnchor = otherAnchor.
    @objc func pin(equalTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(equalTo: anchor).with(priority: .defaultHigh)
    }

    @objc func pin(greaterThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor).with(priority: .defaultHigh)
    }

    @objc func pin(lessThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor).with(priority: .defaultHigh)
    }

    @objc func pin(equalTo anchor: NSLayoutAnchor<AnchorType>, constant float: CGFloat) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: float).with(priority: .defaultHigh)
    }

    @objc func pin(greaterThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>, constant float: CGFloat) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: float).with(priority: .defaultHigh)
    }

    @objc func pin(lessThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>, constant float: CGFloat) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: float).with(priority: .defaultHigh)
    }
}
