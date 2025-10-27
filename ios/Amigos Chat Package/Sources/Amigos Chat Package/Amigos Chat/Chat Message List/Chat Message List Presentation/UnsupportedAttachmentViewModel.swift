//
//  UnsupportedAttachmentViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/10/2025.
//

import Foundation
import StreamChatSwiftUI

struct UnsupportedAttachmentViewModel {

    @Injected(\.appInfo) var appInfo

    private var appStoreURL: URL? {
        guard let id = appInfo?.appstoreId else { return nil }
        return URL(string: "itms-apps://itunes.apple.com/app/id\(id)")
    }

    var appUpdateMarkdownAttributedString: AttributedString? {
        guard let url = appStoreURL else {
            var fallback = AttributedString(appUpdateMessagePrefix + " " + openAppStoreLabel)
            fallback.font = .caption
            return fallback
        }

        let markdown = "\(appUpdateMessagePrefix) [\(openAppStoreLabel)](\(url.absoluteString))"
        if var attributed = try? AttributedString(markdown: markdown) {
            if let range = attributed.range(of: openAppStoreLabel) {
                attributed[range].font = .caption.bold()
                attributed[range].underlineStyle = .single
            }
            return attributed
        } else {
            return nil
        }
    }

    var anUpdateMarkdownRegularString: String {
       "\(appUpdateMessagePrefix) \(openAppStoreLabel)"
    }
}

// MARK: Translations
extension UnsupportedAttachmentViewModel {

    var iosVersionMessage: String {
        Localized.ChatChannel.unsupportedAttachmentOnCurrentOS
    }

    var appUpdateMessagePrefix: String {
        Localized.ChatChannel.unsupportedAttachmentRequiresAppUpdate
    }

    private var openAppStoreLabel: String {
        Localized.ChatChannel.unsupportedAttachmentOpenAppStore
    }
}
