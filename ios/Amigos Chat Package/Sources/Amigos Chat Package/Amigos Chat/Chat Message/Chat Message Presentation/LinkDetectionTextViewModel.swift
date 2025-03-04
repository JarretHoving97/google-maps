//
//  LinkDetectionTextViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/02/2025.
//

import SwiftUI

@MainActor
class LinkDetectionTextViewModel: ObservableObject {

    @Published var tappedUrl: URL?

    let isModerator: Bool

    let isSentByCurrentUser: Bool

    private let text: String

    private let linkDetector = TextLinkDetector()

    init(isSentByCurrentUser: Bool, isModerator: Bool, text: String) {
        self.isSentByCurrentUser = isSentByCurrentUser
        self.isModerator = isModerator
        self.text = text
    }

    var messageText: AttributedString {

        if isModerator {
            return moderatorText(from: text)
        }

        if linkDetector.hasLinks(in: text) {
            return linkify(for: text, attributes: attributes)
        }

        return AttributedString(NSAttributedString(string: text, attributes: attributes))
    }

    private func moderatorText(from text: String) -> AttributedString {
        if let markdownText = markdownAttributedString(from: text) {
            return markdownText
        }

        return AttributedString(NSAttributedString(string: tr(text), attributes: attributes))
    }

    private var attributes: [NSAttributedString.Key: Any] {
        [
            .foregroundColor: isSentByCurrentUser ? UIColor.white : UIColor.darkText,
            .font: UIFont.caption1
        ]
    }

    /// Override link text attributes
    private func linkify(for text: String, attributes: [NSAttributedString.Key: Any]) -> AttributedString {
        // Create an attributed string with the message text and attributes
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: attributes
        )

        let linkColor = isSentByCurrentUser ? UIColor.white : UIColor(.purple)

        // Detect links in the message text
        linkDetector.links(in: text).forEach { textLink in
            attributedText.addAttribute(.link, value: textLink.url, range: textLink.range)
            attributedText.addAttribute(.foregroundColor, value: linkColor, range: textLink.range)
            attributedText.addAttribute(.font, value: UIFont.caption1, range: textLink.range)
            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textLink.range)
        }

        return AttributedString(attributedText)
    }

    /// Detects modern things like markdown links
    func markdownAttributedString(from text: String) -> AttributedString? {
        if var attString = try? AttributedString(markdown: text) {
            /// add attributes to it
            attString.font = UIFont.caption1
            attString.foregroundColor = isSentByCurrentUser ? UIColor.white : UIColor.darkText

            /// find range of links and modify text
            detectMarkdownLinks(with: attString).forEach { range in
                attString[range].foregroundColor = UIColor(.purple)
                attString[range].underlineStyle = [.single]
            }

            return attString
        }

        return nil
    }

    private func detectMarkdownLinks(with text: AttributedString) -> [Range<AttributedString.Index>] {
        var linkRanges: [Range<AttributedString.Index>] = []

        text.runs.forEach { run in
            if run.attributes.link != nil {
                linkRanges.append(run.range)
            }
        }

        return linkRanges
    }

    func handleLinkTap(_ url: URL) {
        let webViewURL = CurrentEnvironment.url
        if let webViewURL, url.host == webViewURL.host {
            RouteController.routeAction?(RouteInfo(route: .path(url.relativePath), dismiss: true))
        } else {
            tappedUrl = url
        }
    }

    func openURL() {
        if let url = tappedUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: Translations

extension LinkDetectionTextViewModel {

    var actionSheetDialogTitle: String {
        tr("custom.message.url.confirm.title")
    }

    var leaveAppButtonTitle: String {
        tr("custom.leaveAmigos")
    }

    var cancelButtonTitle: String {
        tr("custom.cancel")
    }
}
