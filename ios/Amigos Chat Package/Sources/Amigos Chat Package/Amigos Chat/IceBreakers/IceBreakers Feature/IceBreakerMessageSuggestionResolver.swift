//
//  IceBreakerMessageSuggestionResolver.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/02/2026.
//

import Foundation

public final class IceBreakerMessageSuggestionResolver: MessageSuggestionsResolver {

    private let isHost: Bool

    private let participantResolver: any MessageSuggestionsResolver
    private let hostResolver: any MessageSuggestionsResolver

    public init(
        isHost: Bool,
        participantResolver: any MessageSuggestionsResolver,
        hostResolver: any MessageSuggestionsResolver
    ) {
        self.isHost = isHost
        self.participantResolver = participantResolver
        self.hostResolver = hostResolver
    }

    public func resolve(for date: Date) -> [String] {
        if isHost {
           return hostResolver.resolve(for: date)
        } else {
            return participantResolver.resolve(for: date)
        }
    }
}
