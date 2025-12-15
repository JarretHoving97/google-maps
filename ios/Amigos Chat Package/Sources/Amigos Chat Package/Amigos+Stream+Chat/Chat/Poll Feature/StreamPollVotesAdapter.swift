//
//  StreamPollVotesAdapter.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/08/2025.
//

import Foundation
import StreamChat

final class StreamPollVotesAdapter: NSObject, PollVoteListControllerProtocol {

    private let controller: PollVoteListController

    weak var delegate: LocalPollVotesProviderDelegate?

    init(controller: PollVoteListController) {
        self.controller = controller
        super.init()
        controller.delegate = self
    }

    var votes: [LocalPollVote] {
        controller.votes.map { $0.toLocal() }
    }

    var hasLoadedAllVotes: Bool { controller.hasLoadedAllVotes }

    func synchronize(_ completion: ((Error?) -> Void)?) {
        controller.synchronize { [weak self] err in
            guard let self = self else { completion?(err); return }
            DispatchQueue.main.async {
                if let err {
                    self.delegate?.provider(self, didEncounterError: err)
                }
                self.delegate?.provider(self, didUpdateVotes: self.votes)
                completion?(err)
            }
        }
    }

    func loadMoreVotes(limit: Int?, completion: ((Error?) -> Void)?) {
        controller.loadMoreVotes(limit: limit) { [weak self] err in
            guard let self = self else { completion?(err); return }
            DispatchQueue.main.async {
                if let err {
                    self.delegate?.provider(self, didEncounterError: err)
                }
                self.delegate?.provider(self, didUpdateVotes: self.votes)
                completion?(err)
            }
        }
    }
}

extension StreamPollVotesAdapter: PollVoteListControllerDelegate {

    func controller(_ controller: PollVoteListController, didChangeVotes changes: [ListChange<PollVote>]) {

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.provider(self, didUpdateVotes: self.votes)
        }
    }

    func controller(_ controller: PollVoteListController, didUpdatePoll poll: Poll) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.controller(self, didUpdatePoll: poll.toLocal())
        }
    }
}
