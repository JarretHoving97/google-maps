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

            ExtendedStreamPlugin.shared.openChannel(info: chatInfo)
        }

        completionHandler()
    }
}
