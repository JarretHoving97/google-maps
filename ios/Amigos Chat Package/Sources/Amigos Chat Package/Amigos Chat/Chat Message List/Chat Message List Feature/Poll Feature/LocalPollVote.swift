//
//  LocalPollVote.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation

public struct LocalPollVote: Identifiable, Hashable, Equatable {

    /// The unique identifier of the poll vote.
    public let id: String

    /// The date and time when the poll vote was created.
    public let createdAt: Date

    /// The date and time when the poll vote was last updated.
    public let updatedAt: Date

    /// The unique identifier of the poll associated with the vote.
    public let pollId: String

    /// The unique identifier of the option selected in the poll.
    /// This property is optional and may be `nil` if no option was selected.
    public let optionId: String?

    /// A boolean indicating whether the vote is an answer.
    public let isAnswer: Bool

    /// The text of the answer provided in the vote.
    /// This property is optional and may be `nil` if no answer text was provided.
    public let answerText: String?

    /// The user who submitted the vote.
    /// This property is optional and may be `nil` if the vote was submitted anonymously.
    public let user: LocalUser?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: LocalPollVote, rhs: LocalPollVote) -> Bool {
        lhs.id == rhs.id &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt &&
        lhs.pollId == rhs.pollId &&
        lhs.optionId == rhs.pollId &&
        lhs.isAnswer == rhs.isAnswer &&
        lhs.user?.id == rhs.user?.id
    }
}
