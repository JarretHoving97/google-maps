//
//  LocalPollOption.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation

/// Local poll option
public struct LocalPollOption: Hashable, Equatable {
    /// The unique identifier of the poll option.
    public let id: String

    /// The text describing the poll option.
    public var text: String

    /// A list of the latest votes received for this poll option.
    public var latestVotes: [LocalPollVote]

//    /// A dictionary containing custom fields associated with the poll option.
//    /// This property is optional and may be `nil`.
//    public var extraData: [String: St]?

    /// Initializes a new instance of `PollOption`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the poll option. Defaults to a new UUID string.
    ///   - text: The text describing the poll option.
    ///   - latestVotes: A list of the latest votes received for this poll option. Defaults to an empty array.
    ///   - custom: A dictionary containing custom fields associated with the poll option. Defaults to `nil`.
    public init(
        id: String = UUID().uuidString,
        text: String,
        latestVotes: [LocalPollVote] = []
        /* extraData: [String: RawJSON]? = nil */
    ) {
        self.id = id
        self.text = text
        self.latestVotes = latestVotes
        /* self.extraData = extraData */
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension LocalPollOption {

    static var mockOptions: [LocalPollOption] {

        let pollId = UUID().uuidString

        return [
            LocalPollOption(
                text: "Option 1",
                latestVotes: [
                    LocalPollVote(
                        id: .uniqueID,
                        createdAt: Date.now,
                        updatedAt: Date.now,
                        pollId: pollId,
                        optionId: .uniqueID,
                        isAnswer: false,
                        answerText: nil,
                        user: LocalUser(
                            id: UUID().uuidString,
                            name: "Ilonski",
                            imageUrl: ImageURLExamples.portraitImageUrl
                        )
                    ),
                    LocalPollVote(
                        id: .uniqueID,
                        createdAt: Date.now,
                        updatedAt: Date.now,
                        pollId: pollId,
                        optionId: .uniqueID,
                        isAnswer: false,
                        answerText: nil,
                        user: LocalUser(
                            id: UUID().uuidString,
                            name: "Tobyaski",
                            imageUrl: ImageURLExamples.landscapeImageUrl
                        )
                    )
                ]
            ),

            LocalPollOption(
                text: "Option 2",
                latestVotes: [
                    LocalPollVote(
                        id: .uniqueID,
                        createdAt: Date.now,
                        updatedAt: Date.now,
                        pollId: pollId,
                        optionId: .uniqueID,
                        isAnswer: false,
                        answerText: nil,
                        user: LocalUser(
                            id: UUID().uuidString,
                            name: "Ilonski",
                            imageUrl: ImageURLExamples.portraitImageUrl
                        )
                    ),
                    LocalPollVote(
                        id: .uniqueID,
                        createdAt: Date.now,
                        updatedAt: Date.now,
                        pollId: pollId,
                        optionId: .uniqueID,
                        isAnswer: false,
                        answerText: nil,
                        user: LocalUser(
                            id: UUID().uuidString,
                            name: "Tobyaski",
                            imageUrl: ImageURLExamples.landscapeImageUrl
                        )
                    )
                ]
            ),

            LocalPollOption(
                text: "Option 3",
                latestVotes: [
                    LocalPollVote(
                        id: .uniqueID,
                        createdAt: Date.now,
                        updatedAt: Date.now,
                        pollId: pollId,
                        optionId: .uniqueID,
                        isAnswer: false,
                        answerText: nil,
                        user: LocalUser(
                            id: UUID().uuidString,
                            name: "Ilonski",
                            imageUrl: ImageURLExamples.portraitImageUrl
                        )
                    ),
                    LocalPollVote(
                        id: .uniqueID,
                        createdAt: Date.now,
                        updatedAt: Date.now,
                        pollId: pollId,
                        optionId: .uniqueID,
                        isAnswer: false,
                        answerText: nil,
                        user: LocalUser(
                            id: UUID().uuidString,
                            name: "Tobyaski",
                            imageUrl: ImageURLExamples.landscapeImageUrl
                        )
                    )
                ]
            ),
        ]
    }
}
