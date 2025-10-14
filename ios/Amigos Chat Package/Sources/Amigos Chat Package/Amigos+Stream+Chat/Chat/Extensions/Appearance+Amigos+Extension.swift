//
//  Appearance+Amigos+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

import StreamChatSwiftUI
import SwiftUI

public extension Appearance {

    static var amigosAppearance: Appearance {
        var colors = ColorPalette()

        colors.quotedMessageBackgroundCurrentUser = UIColor(white: 0.0, alpha: 0.05)
        colors.quotedMessageBackgroundOtherUser = UIColor(white: 0.0, alpha: 0.05)
        colors.messageCurrentUserBackground = [UIColor(Color("Purple"))]
        colors.messageOtherUserBackground = [UIColor.white]
        colors.messageCurrentUserTextColor = UIColor.white
        colors.tintColor = Color("Purple")
        colors.background = .white

        let images = Images()
        // MARK: Disable sending extended available reactions to match android
        // We do support recognizing them for now but we can't send them.
        images.availableReactions = [
            .init(rawValue: "thumbs-up"): ChatMessageReactionAppearance(
                smallIcon: "👍".toImage(size: 64),
                largeIcon: "👍".toImage(size: 256)
            ),
            .init(rawValue: "heart"): ChatMessageReactionAppearance(
                smallIcon: "❤️".toImage(size: 64),
                largeIcon: "❤️".toImage(size: 256)
            ),
            .init(rawValue: "tears-of-joy"): ChatMessageReactionAppearance(
                smallIcon: "😂".toImage(size: 64),
                largeIcon: "😂".toImage(size: 256)
            ),
            .init(rawValue: "astonished"): ChatMessageReactionAppearance(
                smallIcon: "😲".toImage(size: 64),
                largeIcon: "😲".toImage(size: 256)
            ),
//            .init(rawValue: "cry"): ChatMessageReactionAppearance(
//                smallIcon: "😥".toImage(size: 64),
//                largeIcon: "😥".toImage(size: 256)
//            ),
//            .init(rawValue: "pray"): ChatMessageReactionAppearance(
//                smallIcon: "🙏".toImage(size: 64),
//                largeIcon: "🙏".toImage(size: 256)
//            ),
            .init(rawValue: "fire"): ChatMessageReactionAppearance(
                smallIcon: "🔥".toImage(size: 64),
                largeIcon: "🔥".toImage(size: 256)
            ),
//            .init(rawValue: "tada"): ChatMessageReactionAppearance(
//                smallIcon: "🎉".toImage(size: 64),
//                largeIcon: "🎉".toImage(size: 256)
//            ),
//            .init(rawValue: "thumbsdown"): ChatMessageReactionAppearance(
//                smallIcon: "👎".toImage(size: 64),
//                largeIcon: "👎".toImage(size: 256)
//            ),
//            .init(rawValue: "star-struck"): ChatMessageReactionAppearance(
//                smallIcon: "🤩".toImage(size: 64),
//                largeIcon: "🤩".toImage(size: 256)
//            ),
//            .init(rawValue: "white_check_mark"): ChatMessageReactionAppearance(
//                smallIcon: "✅".toImage(size: 64),
//                largeIcon: "✅".toImage(size: 256)
//            ),
//            .init(rawValue: "thinking_face"): ChatMessageReactionAppearance(
//                smallIcon: "🤔".toImage(size: 64),
//                largeIcon: "🤔".toImage(size: 256)
//            )
        ]

        images.sliderThumb = UIImage(named: "SliderThumb")!

        return Appearance(colors: colors, images: images, fonts: Fonts())
    }

}
