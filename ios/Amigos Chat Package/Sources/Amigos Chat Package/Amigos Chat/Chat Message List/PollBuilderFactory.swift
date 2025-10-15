//
//  PollBuilderFactory.swift
//  Amigos Chat Package
//
//  Created by Jarret on 15/10/2025.
//

import Foundation
import StreamChat

enum PollBuilderFactory {

    static func build(client: ChatClient) -> PollControllerBuilder? {
        return { [weak client] messageId, pollId in
            guard let client else { return nil }
            return PollControllerAdapter(client.pollController(messageId: messageId, pollId: pollId))
        }
    }
}
