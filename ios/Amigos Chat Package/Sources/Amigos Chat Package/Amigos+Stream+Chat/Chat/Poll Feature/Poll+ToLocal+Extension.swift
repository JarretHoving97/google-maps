//
//  Poll+ToLocal+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import StreamChat

extension Poll: LocalMappable {

    public func toLocal() -> LocalPoll {
        return LocalPoll(
            allowAnswers: allowAnswers,
            allowUserSuggestedOptions: allowUserSuggestedOptions,
            answersCount: answersCount,
            createdAt: createdAt,
            pollDescription: pollDescription,
            enforceUniqueVote: enforceUniqueVote,
            id: id,
            name: name,
            updatedAt: updatedAt,
            voteCount: voteCount,
            voteCountsByOption: voteCountsByOption,
            isClosed: isClosed,
            maxVotesAllowed: maxVotesAllowed,
            votingVisibility: LocalVotingVisibility(rawValue: votingVisibility?.rawValue ?? ""),
            createdBy: createdBy?.toLocal(),
            latestAnswers: latestAnswers.toLocal(),
            options: options.toLocal(),
            latestVotesByOption: latestVotesByOption.toLocal(),
            latestVotes: latestVotes.toLocal(),
            ownVotes: ownVotes.toLocal()
        )
    }
}
