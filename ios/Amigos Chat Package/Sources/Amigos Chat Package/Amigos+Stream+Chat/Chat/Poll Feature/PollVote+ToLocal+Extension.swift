//
//  File.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation
import StreamChat

extension PollVote: LocalMappable {

    public func toLocal() -> LocalPollVote {
        LocalPollVote(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            pollId: pollId,
            optionId: optionId,
            isAnswer: isAnswer,
            answerText: answerText,
            user: user?.toLocal()
        )
    }
}
