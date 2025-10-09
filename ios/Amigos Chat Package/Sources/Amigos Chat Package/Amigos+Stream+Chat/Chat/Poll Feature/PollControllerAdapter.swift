//
//  PollControllerAdapter.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import StreamChat

public final class PollControllerAdapter: PollControllerProtocol, PollControllerDelegate {

    private let wrapped: PollController

    public weak var delegate: LocalPollControllerDelegate?

    public init(_ controller: PollController) {
        self.wrapped = controller
        controller.delegate = self
    }

    // MARK: - PollControllerProtocol

    public var localPoll: LocalPoll? {
        wrapped.poll?.toLocal()
    }

    public var localOwnVotes: [LocalPollVote] {
        wrapped.ownVotes.map { $0.toLocal() }
    }

    public func synchronize(_ completion: ((PollError?) -> Void)?) {
        wrapped.synchronize { error in
            completion?(error.map { _ in .notImplemented })
        }
    }

    public func castPollVote(answerText: String?, optionId: String?, completion: ((Error?) -> Void)?) {
        wrapped.castPollVote(answerText: answerText, optionId: optionId, completion: completion)
    }

    public func removePollVote(voteId: String, completion: ((Error?) -> Void)?) {
        wrapped.removePollVote(voteId: voteId, completion: completion)
    }

    public func closePoll(completion: ((Error?) -> Void)?) {
        wrapped.closePoll(completion: completion)
    }

    public func suggestPollOption(
        text: String,
        position: Int?,
        extraData: [String: String]?,
        completion: ((Error?) -> Void)?
    ) {
        wrapped.suggestPollOption(text: text, position: position, extraData: extraData?.mapValues { .string($0) }, completion: completion)
    }

    public func pollController(_ controller: PollController, didUpdatePoll change: EntityChange<Poll>) {
        delegate?.pollController(self, didUpdatePoll: controller.poll?.toLocal() ?? LocalPoll(name: "", options: []))
    }

    public func pollController(_ controller: PollController, didUpdateCurrentUserVotes changes: [ListChange<PollVote>]) {
        delegate?.pollController(self, didUpdateCurrentUserVotes: controller.ownVotes.map { $0.toLocal() })
    }
}
