import Foundation
import NotificationCenter
import Amigos_Chat_Package

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static var current = NotificationHandler()

    private override init() {}

    // on receive
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let info = notification.request.content.userInfo

        /// Hide notification if user is already in current channel
        let incomingChannelId = info["cid"] as? String
        if case let .channel(currentChannelId) = ChatFeatureState.shared.currentScreen, let incomingChannelId, incomingChannelId == currentChannelId {
            completionHandler([])
            return
        }

        /// also hide notification while in channels list.
        /// channels with new notifications pops up already
        if case .channelsList = ChatFeatureState.shared.currentScreen {
            completionHandler([])
        }

        // show notification
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

            ExtendedStreamPlugin.shared.openChannel(info: chatInfo, showChatOnly: false)
        }

        completionHandler()
    }
}
