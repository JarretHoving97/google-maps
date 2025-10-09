//
//  MockPollController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/09/2025.
//

import SwiftUI

class MockPollController: PollControllerProtocol, ObservableObject {

    var messageId: String = ""

    init(localPoll: LocalPoll? = nil, localOwnVotes: [LocalPollVote], delegate: (any LocalPollControllerDelegate)? = nil) {
        self.localPoll = localPoll
        self.localOwnVotes = localOwnVotes
        self.delegate = delegate
    }

    var localPoll: LocalPoll?

    @Published var localOwnVotes: [LocalPollVote]

    var delegate: (any LocalPollControllerDelegate)?

    func synchronize(_ completion: ((PollError?) -> Void)?) {
        completion?(.notImplemented)
    }

    func castPollVote(answerText: String?, optionId: String?, completion: (((any Error)?) -> Void)?) {
        completion?(.none)
    }

    func removePollVote(voteId: String, completion: (((any Error)?) -> Void)?) {
        completion?(.none)
    }

    func closePoll(completion: (((any Error)?) -> Void)?) {
        completion?(.none)
    }

    func suggestPollOption(text: String, position: Int?, extraData: [String : String]?, completion: (((any Error)?) -> Void)?) {
        completion?(.none)
    }
}
