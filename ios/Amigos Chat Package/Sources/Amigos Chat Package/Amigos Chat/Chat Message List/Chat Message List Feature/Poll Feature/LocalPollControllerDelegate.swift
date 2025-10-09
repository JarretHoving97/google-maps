//
//  LocalPollControllerDelegate.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import Foundation

public protocol LocalPollControllerDelegate: AnyObject {

    func pollController(
        _ pollController: PollControllerProtocol,
        didUpdatePoll poll: LocalPoll
    )
    func pollController(
        _ pollController: PollControllerProtocol,
        didUpdateCurrentUserVotes votes: [LocalPollVote]
    )
}
