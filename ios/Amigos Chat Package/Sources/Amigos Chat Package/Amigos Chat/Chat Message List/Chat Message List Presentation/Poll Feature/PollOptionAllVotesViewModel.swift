//
//  PollOptionAllVotesViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/08/2025.
//

import Combine
import SwiftUI

class PollOptionAllVotesViewModel: ObservableObject {

    let option: LocalPollOption
    let controller: PollVoteListControllerProtocol
    @Published var poll: LocalPoll
    @Published var pollVotes = [LocalPollVote]()
    @Published var errorShown = false

    private var cancellables = Set<AnyCancellable>()
    private(set) var animateChanges = false
    private var loadingVotes = false

    init(
        poll: LocalPoll,
        option: LocalPollOption,
        controller: PollVoteListControllerProtocol
    ) {
        self.poll = poll
        self.option = option
        self.controller = controller

        controller.delegate = self

        refresh()

        $pollVotes
            .dropFirst()
            .map { _ in true }
            .assignWeakly(to: \.animateChanges, on: self)
            .store(in: &cancellables)
    }

    func refresh() {
        controller.synchronize { [weak self] error in
            DispatchQueue.main.async { [error] in
                if error != nil {
                    self?.errorShown = true
                }
                self?.pollVotes = self?.controller.votes ?? []
            }
        }
    }

    func onAppear(vote: LocalPollVote) {

        guard let index = pollVotes.firstIndex(where: { $0 == vote }) else {
            return
        }

        guard index > pollVotes.count - 10 && pollVotes.count > 24 else {
            return
        }

        loadVotes()

    }

    func loadVotes() {

        if loadingVotes || controller.hasLoadedAllVotes {
            return
        }

        loadingVotes = true

        self.controller.loadMoreVotes(limit: nil) { [weak self] error in
            DispatchQueue.main.async { [error] in
                self?.loadingVotes = false
                if error != nil { self?.errorShown = true }
                self?.pollVotes = self?.controller.votes ?? []
            }
        }
    }
}

extension PollOptionAllVotesViewModel: LocalPollVotesProviderDelegate {

    func controller(_ controller: any PollVoteListControllerProtocol, didUpdatePoll poll: LocalPoll) {
        self.poll = poll
    }

    func provider(_ provider: PollVoteListControllerProtocol, didUpdateVotes votes: [LocalPollVote]) {

        if animateChanges {
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.pollVotes = votes
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.pollVotes = votes
            }
        }
    }

    func provider(_ provider: PollVoteListControllerProtocol, didEncounterError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.errorShown = true
        }
    }
}

extension Publisher where Failure == Never {
    /// Assigns each element from a publisher to a property on an object without retaining the object.
    func assignWeakly<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on root: Root
    ) -> AnyCancellable {
        sink { [weak root] in
            root?[keyPath: keyPath] = $0
        }
    }
}
