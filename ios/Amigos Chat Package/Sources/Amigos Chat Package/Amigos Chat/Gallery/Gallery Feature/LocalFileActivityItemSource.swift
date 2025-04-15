//
//  LocalFileActivityItemSource.swift
//
//
//  Created by Jarret on 15/04/2025.
//

import Foundation
import UIKit.UIActivity

/// A custom activity item source that provides a URL for sharing.
/// This class conforms to the `UIActivityItemSource` protocol and is used to
/// provide a URL item for sharing in a `UIActivityViewController`.
class LocalFileActivityItemSource: NSObject, UIActivityItemSource {

    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return url
    }
}
