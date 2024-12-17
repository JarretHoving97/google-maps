import Foundation
import NotificationCenter

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static var current = NotificationHandler()

    private override init() {}

    // on receive
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .badge, .sound]])
    }

    // on push tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleInCapacitor(with: response)
        
        let userInfo = response.notification.request.content.userInfo

        guard let action: LaunchAction = .create(for: userInfo) else {
            completionHandler()
            return
        }

        switch action {
        // open stream chat
        case let .streamChat(chatInfo):
            // @TODO: If this is called from a closed app-state, the WebView most likely won't be done loading the navigation strategy. Therefor, `notifyNavigateToListeners()` will do nothing. For apps running on the background this will work.
            ExtendedStreamPlugin.shared.notifyNavigateToListeners(route: "/channel/\(chatInfo.channelId)")
            ExtendedStreamPlugin.shared.initializeViewController(info: chatInfo)
        }

        completionHandler()
    }
}
