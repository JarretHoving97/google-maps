//
//  LocalPollEvent.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import Foundation

public enum LocalPollEvent {
    case pollUpdate(LocalPoll?)
    case ownVotesUpdated([LocalPollVote])
}

public protocol LocalPollObserver: AnyObject {
    func didReceive(event: LocalPollEvent)
}
