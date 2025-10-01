//
//  MessageActionResolver.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/09/2025.
//

import Foundation

public enum MessageActionResolver {

    private static func resolve(urlString: String?, isSentByCurrentUser: Bool, messageType: MessageType) -> MessageActionButton? {
        guard
            let urlString,
            let actionURL = URL(string: urlString),
            let webViewURL = CurrentEnvironment.url,
            let actionHost = actionURL.host,
            let webHost = webViewURL.host,
            actionHost == webHost
        else {
            return nil
        }

        let absolute = actionURL.absoluteString
        guard let hostRange = absolute.range(of: webHost) else {
            return nil
        }
        let pathWithLeading = String(absolute[hostRange.upperBound...])

        return MessageActionButton(
            path: pathWithLeading,
            isSentByCurrentUser: isSentByCurrentUser,
            messageType: messageType
        )
    }

    static func resolve(from message: Message) -> MessageActionButton? {
        return resolve(
            urlString: message.actionUrl,
            isSentByCurrentUser: message.isSentByCurrentUser,
            messageType: message.type
        )
    }
}
