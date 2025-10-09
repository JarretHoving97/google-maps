//
//  PollResultsViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 02/09/2025.
//

import Foundation

@MainActor
class PollResultsViewModel: ObservableObject {

    var controller: PollControllerProtocol

    @Published var poll: LocalPoll

    private let isSentByCurrentUser: Bool

    var options: [LocalPollOption] {
        return poll.options
    }

    convenience init(viewModel: PollMessageViewModel) {
        self.init(
            controller: viewModel.controller,
            poll: viewModel.poll,
            isSentByCurrentUser: viewModel.isSentByCurrentUser
        )
    }

    init(
        controller: PollControllerProtocol,
        poll: LocalPoll,
        isSentByCurrentUser: Bool
    ) {
        self.controller = controller
        self.poll = poll
        self.isSentByCurrentUser = isSentByCurrentUser
    }

    func currentUserVoteId(for option: LocalPollOption) -> String? {
        return poll.currentUserVote(for: option)?.id
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

    func hasMostVotes(for option: LocalPollOption) -> Bool {
        poll.isOptionWithMostVotes(option)
    }
}
