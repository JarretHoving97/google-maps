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

                // check if we have a sender image
                guard let senderImage = author.imageURL else {
                    completion(content)
                    return
                }

                makeCommunicationNotification(
                    channelId: channelId,
                    imageURL: senderImage,
                    title: channelName,
                    body: message,
                    author: author,
                    members: members,
                    content: content

                ) { [weak self, completion, imageAttachments] content in
                    // download attachments if any
                    guard let self else { return }

                    // download only first attachments for now..
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
        channelId: String,
        imageURL: URL,
        title: String,
        body: String,
        author: ChatUser,
        members: [ChatChannelMember],
        content: UNMutableNotificationContent,
        completion: @escaping (UNMutableNotificationContent) -> Void
    ) {
        downloadAndSaveImageTemporaly(url: imageURL) { localURL in

            guard let url = localURL, let senderImageData = try? Data(contentsOf: url) else {
                return
            }

            let senderAvatar: INImage = INImage(imageData: senderImageData)

            var senderDisplayName = PersonNameComponents()
            senderDisplayName.nickname = author.name

            let senderPerson = INPerson(
                personHandle: INPersonHandle(
                    value: author.id,
                    type: .unknown
                ),
                nameComponents: senderDisplayName,
                displayName: author.name,
                image: senderAvatar,
                contactIdentifier: nil,
                customIdentifier: nil
            )
            /// Mapping all channel members to INPerson
            /// `https://developer.apple.com/documentation/usernotifications/implementing-communication-notifications`
            ///  could be important for grouping notifications
            let recipents = members.map { member in
                let name = member.name
                var personNameComponents = PersonNameComponents()
                personNameComponents.nickname = member.name

                return INPerson(
                    personHandle: INPersonHandle(
                        value: member.userId.uuidString,
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
                content: body,
                speakableGroupName: INSpeakableString(spokenPhrase: title),
                conversationIdentifier: title,
                serviceName: nil,
                sender: senderPerson,
                attachments: nil
            )

            incomingMessagingIntent.setImage(senderAvatar, forParameterNamed: \.speakableGroupName)

            let interaction = INInteraction(intent: incomingMessagingIntent, response: nil)

            interaction.direction = .incoming

            content.threadIdentifier = title
            content.body = body

            do {
                // we now update / patch / convert our attempt to a communication notification.
                let bestAttemptContent = try content.updating(from: incomingMessagingIntent) as? UNMutableNotificationContent

                // group by channel
                bestAttemptContent?.threadIdentifier = channelId

                // everything went alright, we are ready to display our notification.
                completion(bestAttemptContent!)

            } catch let error {
                print("error \(error)")
            }
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
