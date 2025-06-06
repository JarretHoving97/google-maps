//
//  MessageContainerComposer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import StreamChatSwiftUI
import Foundation

class MessageContainerComposer {

    static private let messageMapper = MessageMapper()

    @MainActor
    static func compose(
        with message: ChatMessageProtocol,
        isMessagePinned: Bool = false,
        width: CGFloat = .messageWidth,
        showsAllinfo: Bool,
        isLast: Bool,
        isDirectMessageChat: Bool = false,
        isRead: Bool,
        isReadByAll: Bool,
        imageLoader: ImageLoader = NukeImageLoader(),
        imageCDN: ImageCDNhandler = StreamImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader(),
        onQuotedMessageTap: @escaping ((String) -> Void) = {_ in },
        onMessageReply: @escaping (() -> Void) = {},
        onReactionTap: @escaping ((ReactionType) -> Void) = {_ in },
        onReactionsTap: @escaping ((String) -> Void) = {_ in },
        onLongPress: @escaping LongPressInfo = {_ in }

    ) -> MessageContainerView {

        let message = messageMapper.map(message)

        let viewModel = MessageContainerViewModel(
            message: message,
            showsAllInfo: showsAllinfo,
            isMessagePinned: isMessagePinned,
            isLast: isLast,
            isDirectMessageChat: isDirectMessageChat,
            isRead: isRead,
            isReadByAll: isReadByAll,
            imageLoader: imageLoader,
            imageCDN: imageCDN,
            videoPreviewLoader: videoPreviewLoader
        )

        return MessageContainerView(
            viewModel: viewModel,
            onQuotedMessageTap: onQuotedMessageTap,
            onMessageReply: onMessageReply,
            onReactionsTap: onReactionsTap,
            onLongPress: onLongPress,
            width: width
        )
    }
}
