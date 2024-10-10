import Foundation
import StreamChatSwiftUI
import SwiftUI
import StreamChat

func linkify(for text: String, attributes: [NSAttributedString.Key: Any]) -> AttributedString? {
    // Create an attributed string with the message text and attributes
    let attributedText = NSMutableAttributedString(
        string: text,
        attributes: attributes
    )
    
    let linkDetector = TextLinkDetector()
    
    // Only continue if the message has links in it.
    guard linkDetector.hasLinks(in: text) else { return nil }
    
    // Detect links in the message text
    linkDetector.links(in: text).forEach { textLink in
        attributedText.addAttribute(.link, value: textLink.url, range: textLink.range)
        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textLink.range)
    }
        
    return AttributedString(attributedText)
}
