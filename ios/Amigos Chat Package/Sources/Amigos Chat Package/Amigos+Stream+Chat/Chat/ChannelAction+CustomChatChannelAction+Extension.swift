//
//  ChannelAction+CustomChatChannelAction+Extension
//  Amigos Chat Package
//
//  Created by Jarret on 10/11/2025.
//

import Foundation
import StreamChatSwiftUI

extension CustomChannelAction {

    init(from channelAction: ChannelAction) {
        self.title = channelAction.title
        self.action = channelAction.action
        self.iconName = channelAction.iconName
        self.isDestructive = channelAction.isDestructive

        if let confirmationPopup = channelAction.confirmationPopup {
            self.confirmationInfo = CustomConfirmationInfo(
                title: confirmationPopup.title,
                buttonTitle: confirmationPopup.buttonTitle,
                message: confirmationPopup.message ?? ""
            )
        } else {
            self.confirmationInfo = nil
        }
    }
}
