//
//  NotificationHandler+CAP+Extension.swift
//  App
//
//  Created by Jarret on 16/12/2024.
//

import Capacitor

extension NotificationHandler {

    func handleInCapacitor(with response: UNNotificationResponse) {
        var data = JSObject()
        let actionId = response.actionIdentifier

        if actionId == UNNotificationDefaultActionIdentifier {
            data["actionId"] = "tap"
        } else if actionId == UNNotificationDismissActionIdentifier {
            data["actionId"] = "dismiss"
        } else {
            data["actionId"] = actionId
        }

        if let inputType = response as? UNTextInputNotificationResponse {
            data["inputValue"] = inputType.userText
        }

        let request = response.notification.request

        data["notification"] = makeNotificationRequestJSObject(request)

        if request.content.userInfo["url"] is String {
            // If the url property we will navigate to it on the WebView.
            // We need want to dismiss the view controller so it won't show on top.
            ExtendedStreamPlugin.shared.dismiss()
        }

        let pushNotificationsPlugin = ExtendedStreamPlugin.shared.bridge?.plugin(withName: "PushNotifications")
        pushNotificationsPlugin?.notifyListeners("pushNotificationActionPerformed", data: data, retainUntilConsumed: true)

    }

    private func makeNotificationRequestJSObject(_ request: UNNotificationRequest) -> JSObject {
        return [
            "id": request.identifier,
            "title": request.content.title,
            "subtitle": request.content.subtitle,
            "badge": request.content.badge ?? 1,
            "body": request.content.body,
            "data": JSTypes.coerceDictionaryToJSObject(request.content.userInfo) ?? [:]
        ]
    }
}
