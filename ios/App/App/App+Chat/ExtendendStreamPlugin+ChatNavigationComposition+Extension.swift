//
//  ExtendendStreamPlugin+.swift
//  App
//
//  Created by Jarret on 16/12/2024.
//

import UIKit
import StreamChat
import SwiftUI
import Amigos_Chat_Package

struct ChatPresentationModel {
    let channel: ChannelInfo
    let showChatOnly: Bool

    init(channel: ChannelInfo, showChatOnly: Bool = false) {
        self.channel = channel
        self.showChatOnly = showChatOnly
    }
}

extension ExtendedStreamPlugin {

    /// initialize chat if no instance can be found.
    func openChannel(info: ChannelInfo, showChatOnly: Bool = true) {
        if chatRouter != nil {
            routeToChannel(with: info)
        } else {

            let model = ChatPresentationModel(
                channel: ChannelInfo(channelId: info.channelId),
                showChatOnly: showChatOnly
            )

            initializeViewController(model: model)
        }
    }

    private func routeToChannel(
        with channel: ChannelInfo,
        loadChannel: Bool = true,
        animated: Bool = true
    ) {
        Task { @MainActor in chatRouter?.push(.conversation(.channelInfo(channel))) }
    }
}

extension ExtendedStreamPlugin {

    func getAppInfo() -> AppInfo? {
        guard let appStoreId = Bundle.main.object(forInfoDictionaryKey: "AppStoreID") as? String else {

            print("Could not get any AppStoreID, did you add this in the info.plist file?")
            return nil
        }

        return AppInfo(appstoreId: appStoreId)
    }
}
