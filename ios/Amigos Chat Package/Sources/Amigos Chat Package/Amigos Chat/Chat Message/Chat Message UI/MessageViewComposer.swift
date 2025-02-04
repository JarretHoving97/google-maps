//
//  MessageViewComposer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 23/01/2025.
//

import StreamChatSwiftUI
import Foundation

struct MessageViewComposer {

    static private let messageMapper = MessageMapper()

    static public func composeWith(
        with message: ChatMessageProtocol,
        isFirst: Bool,
        forceLeftToRight: Bool,
        width: CGFloat = .messageWidth,
        imageLoader: ImageLoader = NukeImageLoader(),
        imageCDN: ImageCDNhandler = StreamImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader()

    ) -> MessageView {

        let message = messageMapper.map(message)

        let viewModel = MessageViewModel(
            message: message,
            imageLoader: imageLoader,
            imageCDN: imageCDN,
            videoPreviewLoader: videoPreviewLoader,
            isFirst: isFirst
        )
        return MessageView(viewModel: viewModel, width: width)
    }
}
