//
//  MessageContainerViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import SwiftUI

typealias IsReadByAllHandler = (Message) -> Bool

class MessageContainerViewModel: ObservableObject {

    @Published var showReactionsOverlay: Bool = false

    private var isAnonymous: Bool {
        return LayoutMessageType(rawValue: message.layoutKey ?? "") == .anonymous
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }

    let message: Message
    let showsAllInfo: Bool
    let isLast: Bool
    let isDirectMessageChat: Bool

    var imageLoader: ImageLoader
    var imageCDN: ImageCDNhandler
    var videoPreviewLoader: PreviewVideoLoader

    var author: LocalUser {
        return message.user
    }

    @MainActor
    lazy var cdnAuthorImageURL: URL? = {
        guard let url = message.user.imageUrl else { return nil }
        return imageCDN.thumbnailURL(originalURL: url, preferredSize: CGSize(width: 36, height: 36))
    }()

    var time: String {
        return dateFormatter.string(from: message.createdAt)
    }

    var isRightAligned: Bool {
        return message.isSentByCurrentUser
    }

    var showAvatar: Bool {
        return !isRightAligned && showsAllInfo && !isAnonymous
    }

    var reactions: [ReactionType: Int] {
        return message.reactions
    }

    var sendingState: Message.LocalState? {
        return message.localState
    }

    var showFooterView: Bool {
        showsAllInfo &&
        !message.isDeleted &&
        /// moderator accounts can be used for some notifications we want to hide the moderator information.
        !isAnonymous
    }

    var layoutKey: String? {
        return message.layoutKey
    }

    let isRead: Bool

    private let isReadByAllHandler: IsReadByAllHandler

    init(
        message: Message,
        showsAllInfo: Bool,
        isLast: Bool,
        isDirectMessageChat: Bool,
        isRead: Bool = false,
        isReadByAllHandler: @escaping IsReadByAllHandler = { _ in false },
        imageLoader: ImageLoader = DefaultImageLoader(),
        imageCDN: ImageCDNhandler = MockImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader()
    ) {
        self.message = message
        self.showsAllInfo = showsAllInfo
        self.imageLoader = imageLoader
        self.isRead = isRead
        self.isReadByAllHandler = isReadByAllHandler
        self.imageCDN = imageCDN
        self.videoPreviewLoader = videoPreviewLoader
        self.isLast = isLast
        self.isDirectMessageChat = isDirectMessageChat
    }

    var isReadByAll: Bool {
        return isReadByAllHandler(message)
    }
}
