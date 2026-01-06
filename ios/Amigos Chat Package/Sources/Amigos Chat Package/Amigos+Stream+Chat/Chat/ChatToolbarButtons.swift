//
//  ChatToolbarButtons.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/12/2025.
//

import SwiftUI
import StreamChat

struct ChatToolbarButtons: ToolbarContent {

    let channel: ChatChannel
    let router: Router?
    let onMoreTapped: () -> Void

    init(router: Router?, channel: ChatChannel, onMoreTapped: @escaping (() -> Void)) {
        self.router = router
        self.channel = channel
        self.onMoreTapped = onMoreTapped
    }

    var body: some ToolbarContent {
        if !channel.isSupportChatChannel && channel.isDirectMessageChannel, let userId = channel.otherUser?.id {
            ToolbarItem(placement: .topBarTrailing) {
                AmiIconButton {
                    router?.push(.client(.profileInviteRoute(id: userId)))
                } content: {
                    Image("Plus")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                }
                .frame(width: 20, height: 20)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onMoreTapped()
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color(.purple))
            }
        }
    }
}
