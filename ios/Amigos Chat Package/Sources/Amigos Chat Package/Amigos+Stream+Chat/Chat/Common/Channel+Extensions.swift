import StreamChat
import StreamChatSwiftUI
import SwiftUI

enum ChatChannelRelatedConceptType: Equatable {

    @available(*, deprecated, message: "Mixer is deprecated and kept only for backward compatibility with existing data.")
    case mixer(id: String)
    case activity(id: String)
    case community(id: String)
    case standard
}

extension ChatChannelRelatedConceptType {

    var isCommunity: Bool {
        if case .community = self { return true }
        return false
    }
}

extension ChatChannel {

    @available(*, deprecated, message: "Mixer is deprecated and kept only for backward compatibility with existing data.")
    var mixerId: String? {
        if isDirectMessageChannel {
            return nil
        }

        return extraData["mixerId"]?.stringValue
    }

    var activityId: String? {
        if isDirectMessageChannel || mixerId != nil {
            return nil
        }

        return cid.id
    }

    var otherUser: ChatChannelMember? {
        let currentUserId = UserProvider.shared.id

        if isDirectMessageChannel {
            return lastActiveMembers.first(where: { $0.id != currentUserId })
        }

        return nil
    }

    var isCurrentUserOrganizer: Bool {
        let currentUserId = UserProvider.shared.id

        if membership?.memberRole == .organizer {
            return true
        }

        // This is temporary, the initial migration didn't support member roles.
        if let currentUserId, currentUserId == createdBy?.id {
            return true
        }

        return false
    }

    var isSupportChatChannel: Bool {
        otherUser?.userRole == UserRole.moderator
    }

    var subtitleText: String? {
        if shouldShowTypingIndicator {
            let currentUserId = UserProvider.shared.id
            return typingIndicatorString(currentUserId: currentUserId)
        } else if let lastMessageText = lastMessageText {
            return lastMessageText
        }

        return nil
    }

    /// Returns the typing indicator string.
    /// - Parameters:
    ///  - currentUserId: the id of the current user.
    /// - Returns: the typing indicator string.
    public func typingIndicatorString(currentUserId: UserId?) -> String {
        let chatUserNamer = InjectedValues[\.utils].chatUserNamer
        let typingUsers = currentlyTypingUsersFiltered(currentUserId: currentUserId)

        if isDirectMessageChannel {
            return tr("custom.messageList.typingIndicator.user")
        } else if let user = typingUsers.first(where: { user in user.name != nil }), let name = chatUserNamer.name(forUser: user) {
            return tr("messageList.typingIndicator.users", name, typingUsers.count - 1)
        } else {
            // If we somehow cannot fetch any user name, we simply show that `Someone is typing`
            return tr("messageList.typingIndicator.typingUnknown")
        }
    }

    public var lastMessageText: String? {
        guard let latestMessage = latestMessages.first else {
            return nil
        }

        if let text = pollMessageText(for: latestMessage) {
            return text
        }

        let content = textContent(for: latestMessage)

        if latestMessage.isSentByCurrentUser {
            return "\(tr("custom.sendByYou")) \(content)"
        }

        if isDirectMessageChannel {
            return content
        }

        if let authorName = latestMessage.author.name, latestMessage.layoutType != .anonymous {
            return "\(authorName): \(content)"
        }

        return content
    }

    func pollMessageText(for previewMessage: ChatMessage) -> String? {
        guard let poll = previewMessage.poll, !previewMessage.isDeleted else { return nil }
        var components = ["📊"]
        if let latestVoter = poll.latestVotesByOption.first?.latestVotes.first?.user {
            if previewMessage.isSentByCurrentUser {
                components.append(tr("channel.item.poll-you-voted"))
            } else {
                components.append(tr("channel.item.poll-someone-voted", latestVoter.name ?? latestVoter.id))
            }
        } else if let creator = poll.createdBy {
            if previewMessage.isSentByCurrentUser {
                components.append(tr("channel.item.poll-you-created"))
            } else {
                components.append(tr("channel.item.poll-someone-created", creator.name ?? creator.id))
            }
        }
        if !poll.name.isEmpty {
            components.append(poll.name)
        }
        return components.joined(separator: " ")
    }

    private func textContent(for previewMessage: ChatMessage) -> String {
        if let attachmentPreviewText = attachmentPreviewText(for: previewMessage) {
            return attachmentPreviewText
        }
        if let textContent = previewMessage.textContent, !textContent.isEmpty {
            return textContent
        }
        return previewMessage.adjustedText
    }

    /// The message preview text in case it contains attachments.
    /// - Parameter previewMessage: The preview message of the channel.
    /// - Returns: A string representing the message preview text.
    func attachmentPreviewText(for previewMessage: ChatMessage) -> String? {
        guard let attachment = previewMessage.allAttachments.first, !previewMessage.isDeleted else {
            return nil
        }
        let text = previewMessage.textContent ?? previewMessage.text
        switch attachment.type {
        case .audio:
            let defaultAudioText = tr("channel.item.audio")
            return "\(text.isEmpty ? defaultAudioText : text) 🎙️"
        case .file:
            guard let fileAttachment = previewMessage.fileAttachments.first else {
                return nil
            }
            let title = fileAttachment.payload.title
            return "\(title ?? text) 📄"
        case .image:
            let defaultPhotoText = tr("channel.item.photo")
            return "\(text.isEmpty ? defaultPhotoText : text) 📷"
        case .video:
            let defaultVideoText = tr("channel.item.video")
            return "\(text.isEmpty ? defaultVideoText : text) 🎥"
        case .giphy:
            return "/giphy"
        case .voiceRecording:
            let defaultVoiceMessageText = tr("channel.item.voice-message")
            return "\(text.isEmpty ? defaultVoiceMessageText : text) 🎙️"
        case .location:
            return "\(text.isEmpty ? tr("channel.item.location") : text) 📍"
        default:
            return nil
        }
    }
}
