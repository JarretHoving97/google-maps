//
//  PollOptionViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import Foundation

struct PollOptionViewModel: Hashable {

    let option: LocalPollOption

    let isSentByCurrentUser: Bool

    let pollIsClosed: Bool

    let optionVotedByCurrentUser: Bool

    let maxVotes: Int

    let votes: Int

    var latestVoters: [LocalUser] {
        return option.latestVotes.compactMap { $0.user }
    }

    var showVoters: Bool {
        return true
    }

    init(
        option: LocalPollOption,
        isSentByCurrentUser: Bool,
        optionVotedByCurrentUser: Bool = false,
        maxVotes: Int,
        votes: Int,
        pollIsClosed: Bool
    ) {
        self.isSentByCurrentUser = isSentByCurrentUser
        self.option = option
        self.maxVotes = maxVotes
        self.pollIsClosed = pollIsClosed
        self.votes = votes
        self.optionVotedByCurrentUser = optionVotedByCurrentUser
    }
}
