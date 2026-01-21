//
//  StreamChatNotificationHandler.swift
//  App
//
//  Created by Jarret on 23/04/2025.
//

import Foundation
import UIKit.UIImage
import UserNotifications
import Intents
import StreamChat
import StreamChatSwiftUI
import Amigos_Chat_Package
import Amigos_Shared

typealias ChatNotificationHandler = (ChatPushNotificationContent) -> Void

final class StreamChatNotificationHandler {

    private let chatContext = StreamChatContext()

    func handleNotification(
        content: UNMutableNotificationContent,
        originalRequest: UNNotificationRequest,
        completion: @escaping (UNMutableNotificationContent) -> Void
    ) {

        guard let client = chatContext.createChatClient() else {
            completion(content)
            return
        }

        let chatHandler = ChatRemoteNotificationHandler(client: client, content: content)

        // handles notification from chat
        let chatNotification = chatHandler.handleNotification(
            completion: makeCommunicationNotification(
                content: content,
                completion: completion
            )
        )

        if !chatNotification {
            // this was not a notification from Stream Chat
            // perform any other transformation to the notification if needed
            completion(content)
        }
    }
}

// MARK: - Helper functions
extension StreamChatNotificationHandler {

    private func makeCommunicationNotification(
        content: UNMutableNotificationContent,
        completion: @escaping (UNMutableNotificationContent) -> Void
    ) -> ChatNotificationHandler {
        return { [weak self] chatContent in

            guard let self else { return }

            switch chatContent {

            case let .message(messageNotification):

                let author = messageNotification.message.author

                let channelId = messageNotification.channel?.id ?? ""

                let channelName = messageNotification.channel?.name ?? ""

                let message = messageNotification.message.attachmentPreviewText()

                let imageAttachments = messageNotification.message.imageAttachments

                let members = messageNotification.channel?.lastActiveMembers ?? []

                let layoutType = LayoutMessageType(rawValue: messageNotification.message.layoutKey ?? "")

                let isAnonymous = layoutType == .anonymous

                // Resolve sender image URL only when not anonymous
                let senderImageURL: URL? = isAnonymous ? nil : author.imageURL

                makeCommunicationNotification(
                    info: ChatNotificationInfo(
                        channelId: channelId,
                        imageURL: senderImageURL,
                        title: channelName,
                        body: message,
                        author: author,
                        isAnonymous: isAnonymous,
                        members: members
                    ),
                    content: content

                ) { [weak self, completion, imageAttachments] content in
                    // download attachments if any
                    guard let self else { return }

                    // Skip attachments for anonymous messages
                    guard !isAnonymous else {
                        completion(content)
                        return
                    }
                    // download only first attachment for now
                    guard let url = imageAttachments.first?.imageURL else {
                        completion(content)
                        return
                    }
                    addAttachments(url: url, content: content, completion: completion)
                }
            default:
                content.title = "You received an update to one conversation"
                completion(content)
            }
        }

    }

    private func makeCommunicationNotification(
        info: ChatNotificationInfo,
        content: UNMutableNotificationContent,
        completion: @escaping (UNMutableNotificationContent) -> Void
    ) {
        // only download sender image if not anonymous and URL exists
        if !info.isAnonymous, let imageURL = info.imageURL {

            downloadAndSaveImageTemporaly(url: imageURL) { localURL in

                var senderDisplayName = PersonNameComponents()

                senderDisplayName.nickname = info.isAnonymous ? nil : info.author.name

                var senderImage: INImage?

                if let localURL, let data = try? Data(contentsOf: localURL) {
                    senderImage = INImage(imageData: data)
                }

                // build and finalize notification using a helper to avoid duplication
                self.finishBuildingCommunicationNotification(
                    info: info,
                    content: content,
                    senderImage: senderImage,
                    completion: completion
                )
            }
        } else {
            // anonymous or no image URL: build without sender image
            self.finishBuildingCommunicationNotification(
                info: info,
                content: content,
                senderImage: nil,
                completion: completion
            )
        }
    }

    private func finishBuildingCommunicationNotification(
        info: ChatNotificationInfo,
        content: UNMutableNotificationContent,
        senderImage: INImage?,
        completion: @escaping (UNMutableNotificationContent) -> Void
    ) {

        let personHandleValue = info.isAnonymous ? Bundle.appDisplayName : info.author.id

        let senderPerson = INPerson(
            personHandle: INPersonHandle(value: personHandleValue, type: .unknown),
            nameComponents: {
                var comps = PersonNameComponents()
                comps.nickname = info.isAnonymous ? Bundle.appDisplayName : info.author.name
                return comps
            }(),
            displayName: info.isAnonymous ? Bundle.appDisplayName : info.author.name,
            image: info.isAnonymous ? nil : senderImage,
            contactIdentifier: nil,
            customIdentifier: nil
        )

        /// Mapping all channel members to INPerson
        /// `https://developer.apple.com/documentation/usernotifications/implementing-communication-notifications`
        ///  could be important for grouping notifications
        let recipents = info.members.map { member in
            let name = member.name
            var personNameComponents = PersonNameComponents()
            personNameComponents.nickname = member.name

            return INPerson(
                personHandle: INPersonHandle(
                    value: member.userId,
                    type: .unknown
                ),
                nameComponents: personNameComponents,
                displayName: name,
                image: nil,
                contactIdentifier: nil,
                customIdentifier: nil
            )
        }

        let incomingMessagingIntent = INSendMessageIntent(
            recipients: recipents, // > 1 == showing groupname if there there is one
            outgoingMessageType: .unknown,
            content: info.body,
            speakableGroupName: INSpeakableString(spokenPhrase: info.title),
            conversationIdentifier: info.channelId,
            serviceName: nil,
            sender: senderPerson,
            attachments: nil
        )

        if !info.isAnonymous {
            incomingMessagingIntent.setImage(senderImage, forParameterNamed: \.speakableGroupName)
        }

        let interaction = INInteraction(intent: incomingMessagingIntent, response: nil)

        interaction.direction = .incoming
        content.threadIdentifier = info.channelId
        content.body = info.body

        do {
            // we now update / patch / convert our attempt to a communication notification.
            let bestAttemptContent = try content.updating(from: incomingMessagingIntent) as? UNMutableNotificationContent

            // group by channel
            bestAttemptContent?.threadIdentifier = info.channelId

            // everything went alright, we are ready to display our notification.
            completion(bestAttemptContent!)

        } catch let error {
            print("error \(error)")
        }
    }

    private func addAttachments(
        url: URL,
        content: UNMutableNotificationContent,
        identifier: String = "image",
        completion: @escaping (UNMutableNotificationContent) -> Void
    ) {

        downloadAndSaveImageTemporaly(url: url) { [content] localURL in

            guard let localURL else { completion(content); return }

            guard let attachment = try? UNNotificationAttachment(identifier: identifier, url: localURL, options: nil) else {
                return
            }

            content.attachments = [attachment]

            completion(content)
        }
    }

    // downloads image, and saves it to temporary directory returning the local URL
    private func downloadAndSaveImageTemporaly(
        url: URL,
        completion: @escaping (URL?) -> Void
    ) {

        let safeURL = StreamImageCDN().thumbnailURL(originalURL: url, preferredSize: .zero)

        let task = URLSession.shared.downloadTask(with: safeURL) { (downloadedUrl, response, _) in

            guard let downloadedUrl = downloadedUrl else {
                completion(nil)
                return
            }

            do {
                guard MimeTypeSafety.isSafeMimeType(mimeType: response?.mimeType ?? "") else {
                    throw NSError(domain: "Unsafe MIME type", code: 1, userInfo: nil)
                }

                let tempDirectory = FileManager.default.temporaryDirectory

                var localURL = tempDirectory.appendingPathComponent(UUID().uuidString + url.lastPathComponent)

                if localURL.pathExtension.isEmpty {
                    localURL.appendPathExtension("jpeg")
                }

                try FileManager.default.moveItem(at: downloadedUrl, to: localURL)
                completion(localURL)

            } catch {
                debugPrint("Error moving file: \(error)")

                // continue
                completion(nil)
            }
        }
        task.resume()
    }
}
