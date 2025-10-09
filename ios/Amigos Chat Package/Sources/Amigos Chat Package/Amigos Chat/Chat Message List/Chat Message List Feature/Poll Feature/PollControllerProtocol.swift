//
//  PollControllerProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import Foundation

public protocol PollControllerProtocol: AnyObject {

    var localPoll: LocalPoll? { get }

    var localOwnVotes: [LocalPollVote] { get }

    var delegate: LocalPollControllerDelegate? { get set }

    func synchronize(_ completion: ((_ error: PollError?) -> Void)?)

    func castPollVote(answerText: String?, optionId: String?, completion: ((Error?) -> Void)?)

    func removePollVote(voteId: String, completion: ((Error?) -> Void)?)

    func closePoll(completion: ((Error?) -> Void)?)

    func suggestPollOption(text: String, position: Int?, extraData: [String: String]?, completion: ((Error?) -> Void)?)
}
