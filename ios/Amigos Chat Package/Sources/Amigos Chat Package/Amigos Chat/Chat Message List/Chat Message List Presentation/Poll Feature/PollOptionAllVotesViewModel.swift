//
//  PollOptionAllVotesViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/08/2025.
//

import Combine
import SwiftUI

class PollOptionAllVotesViewModel: ObservableObject {

    let poll: LocalPoll
    let option: LocalPollOption
    let controller: PollVoteListControllerProtocol

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
                print(self?.controller.votes.map {$0.user?.name ?? ""} ?? "")
                self?.pollVotes = self?.controller.votes ?? []
            }
        }
    }

    func onAppear(vote: LocalPollVote) {
        guard !loadingVotes,
              !controller.hasLoadedAllVotes,
              let index = pollVotes.firstIndex(where: { $0 == vote }),
              index >= max(0, pollVotes.count - 10) else { return }

        loadVotes()
    }

    private func loadVotes() {

        loadingVotes = true

        controller.loadMoreVotes(limit: nil) { [weak self] error in
            DispatchQueue.main.async { [error] in
                self?.loadingVotes = false
                if error != nil { self?.errorShown = true }
                self?.pollVotes = self?.controller.votes ?? []
            }
        }
    }
}

extension PollOptionAllVotesViewModel: LocalPollVotesProviderDelegate {

    func provider(_ provider: PollVoteListControllerProtocol, didUpdateVotes votes: [LocalPollVote]) {
//        print("controller votes: ")
//        print(self.controller.votes.map {$0.user?.name ?? ""} ?? "")
//
//        print("received votes:)")
//        print(votes.map {$0.user?.name ?? ""})

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
