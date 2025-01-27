//
//  Amigos_ChatApp.swift
//  Amigos Chat
//
//  Created by Jarret on 06/01/2025.
//

import SwiftUI

@main
struct Amigos_ChatApp: App {

    public let apiKeyString = "zcgvnykxsfm8"
    public let applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoAppSwiftUI"
    public let currentUserIdRegisteredForPush = "currentUserIdRegisteredForPush"

    var body: some Scene {
        WindowGroup {
            ChatChannelsComposer.compose(
                with: StreamChatClient(
                    config: StreamChatClient.Config(
                        isLocalStorageEnabled: true,
                        applicationGroupIdentifier: applicationGroupIdentifier,
                        maxAttachmentCountPerMessage: 10,
                        apiKey: apiKeyString
                    )
                )
            )
        }
    }
}
