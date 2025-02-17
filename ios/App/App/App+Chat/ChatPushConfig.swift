//
//  ChatPushConfig.swift
//  App
//
//  Created by Jarret on 10/01/2025.
//

import StreamChat
import Amigos_Chat_Package

class StreamPushConfig: ChatPushConfig {

    var streamClient: ChatClient? {
        ExtendedStreamPlugin.chatClient.chatClient
    }
    /// Adds the device token to stream so push notifications can be sent.
    public func addDeviceToken(deviceToken: String) {

        guard streamClient?.currentUserId != nil else {
            log.warning("[Stream] Failed adding the device as the user is unauthenticated.")
            return
        }

        streamClient?.currentUserController().addDevice(.firebase(token: deviceToken, providerName: "Firebase")) { error in

            if let error = error {
                log.warning("[Stream] Failed adding the device: \(error)")
            }
        }
    }

    public func removeDeviceToken() {

        guard let deviceId = streamClient?.currentUserController().currentUser?.devices.last?.id else {
            return
        }

        streamClient?.currentUserController().removeDevice(id: deviceId) { error in
            if let error = error {
                log.warning("[Stream] Failed removing the device: \(error)")
            }
        }
    }
}
