//
//  LocalPollVotesProviderDelegate.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/08/2025.
//

import Foundation

public protocol LocalPollVotesProviderDelegate: AnyObject {
    func provider(_ provider: PollVoteListControllerProtocol, didUpdateVotes votes: [LocalPollVote])
    func provider(_ provider: PollVoteListControllerProtocol, didEncounterError error: Error)
}
