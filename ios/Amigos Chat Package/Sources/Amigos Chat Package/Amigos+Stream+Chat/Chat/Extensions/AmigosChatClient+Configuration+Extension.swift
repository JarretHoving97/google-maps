//
//  AmigosChatClient+Configuration+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

extension AmigosChatClient {

    public struct LoginInfo {
        let id: String
        let name: String
        let imageUrl: URL?

        public init(id: String, name: String, imageUrl: URL?) {
            self.id = id
            self.name = name
            self.imageUrl = imageUrl
        }
    }

    public struct Config {
        let environment: BuildConfiguration
        let isLocalStorageEnabled: Bool
        let applicationGroupIdentifier: String
        let maxAttachmentCountPerMessage: Int
        let apiKey: String

        var appearence: Appearance = .default
        let utils: Utils

        public init(
            environment: BuildConfiguration,
            isLocalStorageEnabled: Bool,
            applicationGroupIdentifier: String,
            maxAttachmentCountPerMessage: Int,
            apiKey: String,
            appearence: Appearance = .amigosAppearance,
            utils: Utils = .amigosUtils
        ) {
            self.environment = environment
            self.isLocalStorageEnabled = isLocalStorageEnabled
            self.applicationGroupIdentifier = applicationGroupIdentifier
            self.maxAttachmentCountPerMessage = maxAttachmentCountPerMessage
            self.apiKey = apiKey
            self.appearence = appearence
            self.utils = utils
        }
    }
}
