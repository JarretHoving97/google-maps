//
//  MessageContainerViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import SwiftUI

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
    let isMessagePinned: Bool
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

    let isReadByAll: Bool

    init(
        message: Message,
        showsAllInfo: Bool,
        isMessagePinned: Bool,
        isLast: Bool,
        isDirectMessageChat: Bool,
        isRead: Bool = false,
        isReadByAll: Bool = false,
        imageLoader: ImageLoader = DefaultImageLoader(),
        imageCDN: ImageCDNhandler = MockImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader(),
    ) {
        self.message = message
        self.showsAllInfo = showsAllInfo
        self.imageLoader = imageLoader
        self.isRead = isRead
        self.isReadByAll = isReadByAll
        self.imageCDN = imageCDN
        self.videoPreviewLoader = videoPreviewLoader
        self.isMessagePinned = isMessagePinned
        self.isLast = isLast
        self.isDirectMessageChat = isDirectMessageChat
    }
}
