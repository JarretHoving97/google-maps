//
//  PollVoteListControllerProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/08/2025.
//

import Foundation

public protocol PollVoteListControllerProtocol: AnyObject {
    var votes: [LocalPollVote] { get }
    var hasLoadedAllVotes: Bool { get }
    var delegate: LocalPollVotesProviderDelegate? { get set }
    func synchronize(_ completion: ((Error?) -> Void)?)
    func loadMoreVotes(limit: Int?, completion: ((Error?) -> Void)?)
}
