//
//  LocalMessageDisplayListConfiguration.swift
//  Amigos Chat Package
//
//  Created by Jarret on 12/06/2025.
//

import Foundation

typealias DateSeparator = (Message, Message) -> Date?

struct MessageListDisplayConfiguration {

    let messageDisplayOptions: LocalMessageDisplayOptions
    let showUnreadSeparator: Bool

    init(
        messageDisplayOptions: LocalMessageDisplayOptions = LocalMessageDisplayOptions(dateLabelSize: 0),
        showUnreadSeparator: Bool = true
    ) {
        self.messageDisplayOptions = messageDisplayOptions
        self.showUnreadSeparator = showUnreadSeparator
    }

    /// Returns index for a message, only if .messageList date indicator placement is enabled.
    /// - Parameters:
    ///   - message, the message whose index is searched for.
    ///   - messages: the list of messages.
    ///  - Returns: optional index.
    func indexForMessageDate(
        message: Message,
        in messages: [Message]
    ) -> Int? {
        return index(for: message, in: messages)
    }

    /// Returns index for a message, if it exists.
    /// - Parameters:
    ///   - message, the message whose index is searched for.
    ///   - messages: the list of messages.
    ///  - Returns: optional index.
    private func index(
        for message: Message,
        in messages: [Message]
    ) -> Int? {
        let index = messages.firstIndex { msg in
            msg.id == message.id
        }

        return index
    }
}

struct LocalMessageDisplayOptions {
    var dateLabelSize: CGFloat

    var messageDateSeparator: (Message, Message) -> Date? {
        Self.defaultDateSeparator(message:previous:)
    }

    public static func defaultDateSeparator(message: Message, previous: Message) -> Date? {
        let isDifferentDay = !Calendar.current.isDate(
            message.createdAt,
            equalTo: previous.createdAt,
            toGranularity: .day
        )
        if isDifferentDay {
            return message.createdAt
        } else {
            return nil
        }
    }
}
