//
//  LocalPoll.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation

public struct LocalPoll {

    /// A boolean indicating whether the poll allows answers/comments.
    public let allowAnswers: Bool

    /// A boolean indicating whether the poll allows user-suggested options.
    public let allowUserSuggestedOptions: Bool

    /// The count of answers/comments received for the poll.
    public let answersCount: Int

    /// The date and time when the poll was created.
    public  let createdAt: Date

    /// A brief description of the poll.
    /// This property is optional and may be `nil`.
    public  let pollDescription: String?

    /// A boolean indicating whether the poll enforces unique votes.
    public let enforceUniqueVote: Bool

    /// The unique identifier of the poll.
    public  let id: String

    /// The name of the poll.
    public  let name: String

    /// The date and time when the poll was last updated.
    /// This property is optional and may be `nil`.
    public let updatedAt: Date?

    /// The count of votes received for the poll.
    public  let voteCount: Int

    /// A dictionary mapping option IDs to the count of votes each option has received.
    /// This property is optional and may be `nil`.
    public  let voteCountsByOption: [String: Int]?

    /// A boolean indicating whether the poll is closed.
    public  let isClosed: Bool

    /// The maximum number of votes allowed per user.
    /// This property is optional and may be `nil`.
    public let maxVotesAllowed: Int?

    /// Represents the visibility of the voting process.
    /// This property is optional and may be `nil`.
    public let votingVisibility: LocalVotingVisibility?

    public let createdBy: LocalUser?

    public var latestAnswers: [LocalPollVote]

    public var options: [LocalPollOption]

    public var latestVotesByOption: [LocalPollOption]

    public var latestVotes: [LocalPollVote]

    public var ownVotes: [LocalPollVote]

    init(
        allowAnswers: Bool = true,
        allowUserSuggestedOptions: Bool = false,
        answersCount: Int = 0,
        createdAt: Date = Date.now,
        pollDescription: String? = nil,
        enforceUniqueVote: Bool = false,
        id: String = UUID().uuidString,
        name: String,
        updatedAt: Date? = nil,
        voteCount: Int = 0,
        voteCountsByOption: [String : Int]? = nil,
        isClosed: Bool = false,
        maxVotesAllowed: Int? = nil,
        votingVisibility: LocalVotingVisibility? = nil,
        createdBy: LocalUser? = nil,
        latestAnswers: [LocalPollVote] = [],
        options: [LocalPollOption],
        latestVotesByOption: [LocalPollOption] = [],
        latestVotes: [LocalPollVote] = [],
        ownVotes: [LocalPollVote] = []
    ) {
        self.allowAnswers = allowAnswers
        self.allowUserSuggestedOptions = allowUserSuggestedOptions
        self.answersCount = answersCount
        self.createdAt = createdAt
        self.pollDescription = pollDescription
        self.enforceUniqueVote = enforceUniqueVote
        self.id = id
        self.name = name
        self.updatedAt = updatedAt
        self.voteCount = voteCount
        self.voteCountsByOption = voteCountsByOption
        self.isClosed = isClosed
        self.maxVotesAllowed = maxVotesAllowed
        self.votingVisibility = votingVisibility
        self.createdBy = createdBy
        self.latestAnswers = latestAnswers
        self.options = options
        self.latestVotesByOption = latestVotesByOption
        self.latestVotes = latestVotes
        self.ownVotes = ownVotes
    }
}

extension LocalPoll {

    /// The value of the option with the most votes.
    var currentMaximumVoteCount: Int {
        voteCountsByOption?.values.max() ?? 0
    }

    func currentUserVote(for option: LocalPollOption) -> LocalPollVote? {
        ownVotes.first(where: { $0.optionId == option.id })
    }

    func isOptionWithMostVotes(_ option: LocalPollOption) -> Bool {
        let optionsWithMostVotes = voteCountsByOption?.filter { $0.value == currentMaximumVoteCount }
        return optionsWithMostVotes?.count == 1 && optionsWithMostVotes?[option.id] != nil
    }
}
