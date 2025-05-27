//
//  NotificationService.swift
//  NotificationService
//
//  Created by Jarret on 24/04/2025.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var request: UNNotificationRequest?
    var notificationContentHandler = StreamChatNotificationHandler()


    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        self.request = request

        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }

        notificationContentHandler.handleNotification(content: content, originalRequest: request) { modifiedContent in
            contentHandler(modifiedContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = request?.content.mutableCopy() as? UNMutableNotificationContent {
            contentHandler(bestAttemptContent)
        }
    }
}

