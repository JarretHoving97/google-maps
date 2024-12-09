import UserNotifications
import UIKit

extension UNUserNotificationCenter {

    static func resetAppBadge() {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
