//
//  PollMessageViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import SwiftUI

@MainActor
class PollMessageViewModel: ObservableObject {

    @Published private var isClosingPoll = false

    private let message: Message

    var controller: PollControllerProtocol

    var name: String {
        return poll.name
    }

    var isSentByCurrentUser: Bool {
        return message.isSentByCurrentUser
    }

    var subTitleText: String {
        if poll.isClosed {
            return tr("message.polls.subtitle.voteEnded")
        } else if poll.enforceUniqueVote {
            return tr("message.polls.subtitle.selectOne")
        } else if let maxVotes = poll.maxVotesAllowed, maxVotes > 0 {
           return tr("message.polls.subtitle.selectUpTo", min(maxVotes, poll.options.count))
        } else {
            return tr("message.polls.subtitle.selectOneOrMore")
        }
    }

    var options: [PollOptionViewModel] {
        let pollClosed = poll.isClosed
        let maxVotes = poll.currentMaximumVoteCount

        return poll.options.map {
            PollOptionViewModel(
                option: $0,
                isSentByCurrentUser: isSentByCurrentUser,
                optionVotedByCurrentUser: currentUserVoteId(for: $0) != nil,
                maxVotes: maxVotes,
                pollIsClosed: pollClosed
            )
        }
    }

    var poll: LocalPoll {
        return message.poll ?? LocalPoll(name: "", options: [])
    }

    func currentUserVoteId(for option: LocalPollOption) -> String? {
        return poll.currentUserVote(for: option)?.id
    }

    init(message: Message, controller: PollControllerProtocol) {
        self.message = message
        self.controller = controller
    }

    func castPollVote(answerText: String?, optionId: String?, completion: ((Error?) -> Void)?) {
        controller.castPollVote(answerText: answerText, optionId: optionId, completion: completion)
    }

    func removePollVote(voteId: String, completion: ((Error?) -> Void)?) {
        controller.removePollVote(voteId: voteId, completion: completion)
    }

    func toggleVoteAction(_ option: LocalPollOption) {
        if let voteId = currentUserVoteId(for: option) {
            removePollVote(voteId: voteId) { _ in }
        } else {
            castPollVote(answerText: nil, optionId: option.id, completion: {_ in })
        }
    }
}
