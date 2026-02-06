//
//  MessageContainerViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import SwiftUI

typealias IsReadByAllHandler = (Message) -> Bool

struct ActiveThreadIndicatorViewData {
    let replyCount: Int
    let participants: [LocalChatUser]

    var isEmpty: Bool {
        return replyCount == 0
    }
}

// MARK: Translations
extension ActiveThreadIndicatorViewData {

    var replyLabel: String {
        tr("message.threads.count", replyCount)
    }
}

class MessageContainerViewModel: ObservableObject {

    @Published var showReactionsOverlay: Bool = false

    var pollController: PollControllerProtocol?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }

    let message: Message
    let showsAllInfo: Bool
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

    var timeLabel: String {
        let isEdited = message.textUpdatedAt != nil
        let dateLabel = dateFormatter.string(from: message.createdAt)
        return isEdited ? "\(tr("message.cell.edited")) - \(dateLabel)" : dateLabel
    }

    var isRightAligned: Bool {
        return message.isSentByCurrentUser
    }

    var reactions: [ReactionType: Int] {
        return message.reactions
    }

    var sendingState: Message.LocalState? {
        return message.localState
    }

    var showLeftPadding: Bool {
        return !isDirectMessageChat && !isSystemMessage
    }

    var showMessageThreadReplies: Bool {
        !activeThreadViewData.isEmpty &&
        !isInThread &&
        !message.isDeleted
    }

    var showAvatar: Bool {
        !isRightAligned &&
        showsAllInfo &&
        !isAnonymous
    }

    var showFooterView: Bool {
        showsAllInfo &&
        !isAnonymous &&
        !isSystemMessage
    }

    var layoutKey: String? {
        return message.layoutKey
    }

    private var layoutType: LayoutMessageType? {
        return LayoutMessageType(rawValue: message.layoutKey ?? "")
    }

    private var isAnonymous: Bool {
        return layoutType == .anonymous
    }

    private var isSystemMessage: Bool {
        return message.type == .system
    }

    var isDisabled: Bool {
        return message.isDeleted
    }

    @MainActor
    var messagePollViewData: PollMessageViewModel? {
        guard let pollController, message.poll != nil else { return nil }
        return PollMessageViewModel(
            message: message,
            controller: pollController
        )
    }
    var activeThreadViewData: ActiveThreadIndicatorViewData {
        return ActiveThreadIndicatorViewData(
            replyCount: message.replyCount,
            participants: message.threadParticipants
        )
    }

    let isRead: Bool

    private let isInThread: Bool

    private let isReadByAllHandler: IsReadByAllHandler

    private let messagePosition: (Message) -> MessagePosition

    init(
        message: Message,
        showsAllInfo: Bool,
        messagePosition: @escaping (Message) -> MessagePosition = {_ in .alone},
        isDirectMessageChat: Bool,
        isRead: Bool = false,
        pollController: PollControllerProtocol? = nil,
        isInThread: Bool = false,
        isReadByAllHandler: @escaping IsReadByAllHandler = { _ in false },
        imageLoader: ImageLoader = DefaultImageLoader(),
        imageCDN: ImageCDNhandler = MockImageCDN(),
        videoPreviewLoader: PreviewVideoLoader = DefaultPreviewVideoLoader()
    ) {
        self.message = message
        self.showsAllInfo = showsAllInfo
        self.messagePosition = messagePosition
        self.imageLoader = imageLoader
        self.isRead = isRead
        self.isReadByAllHandler = isReadByAllHandler
        self.imageCDN = imageCDN
        self.videoPreviewLoader = videoPreviewLoader
        self.isDirectMessageChat = isDirectMessageChat
        self.pollController = pollController
        self.isInThread = isInThread
    }

    var isReadByAll: Bool {
        return isReadByAllHandler(message)
    }

    var showNameForMessageGroup: Bool {
        return !isDirectMessageChat &&
        !message.isSentByCurrentUser &&
        !isSystemMessage &&
        (position == .top || position == .alone)
    }

    var position: MessagePosition {
        return messagePosition(message)
    }
}
