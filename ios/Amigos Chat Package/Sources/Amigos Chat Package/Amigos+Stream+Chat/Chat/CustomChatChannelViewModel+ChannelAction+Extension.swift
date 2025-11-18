//
//  CustomChatChannelViewModel+ChannelAction+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/11/2025.
//

import Foundation
import StreamChatSwiftUI

extension CustomChannelActionViewModel {

    convenience init(from channelActions: [ChannelAction]) {
        self.init(actions: channelActions.map { CustomChannelAction(from: $0)})
    }
}
