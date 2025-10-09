//
//  LocalPollController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import SwiftUI
import Combine

public final class LocalPollController: LocalPollControllerDelegate {

    private let pollController: PollControllerProtocol

    private let events = PassthroughSubject<LocalPollEvent, Never>()

    public weak var observer: LocalPollObserver?

    public var publisher: AnyPublisher<LocalPollEvent, Never> {
        events.eraseToAnyPublisher()
    }

    public init(controller: PollControllerProtocol) {
        self.pollController = controller
        controller.delegate = self
    }

    public func pollController(_ controller: PollControllerProtocol, didUpdatePoll change: LocalPoll) {
        let latest = controller.localPoll
        events.send(.pollUpdate(latest))
        observer?.didReceive(event: .pollUpdate(latest))
    }

    public func pollController(_ controller: PollControllerProtocol, didUpdateCurrentUserVotes changes: [LocalPollVote]) {
        let latest = Array(controller.localOwnVotes)
        events.send(.ownVotesUpdated(latest))
        observer?.didReceive(event: .ownVotesUpdated(latest))
    }
}
