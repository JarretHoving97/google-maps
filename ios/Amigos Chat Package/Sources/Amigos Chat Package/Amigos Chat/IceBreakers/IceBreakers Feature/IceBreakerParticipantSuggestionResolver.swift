//
//  IceBreakerParticipantSuggestionResolver.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/02/2026.
//

import Foundation

public enum IceBreakerParticipantSuggestionCategory: String {
    case sixDays
}

public class IceBreakerParticipantSuggestionResolver: MessageSuggestionsResolver {

    private let calendar: Calendar

    let now: () -> Date

    private let templates: [IceBreakerParticipantSuggestionCategory: [String]]

    public init(
        calendar: Calendar = .current,
        templates: [IceBreakerParticipantSuggestionCategory: [String]] = [:],
        now: @escaping () -> Date = { Date.now }
    ) {
        self.calendar = calendar
        self.now = now
        self.templates = templates
    }

    public func resolve(for date: Date) -> [String] {
        let current = now()
        guard date > current else { return [] }

        let totalSeconds = date.timeIntervalSince(current)
        let totalDays = Int(totalSeconds / 86400)

        // 5 days window
        if totalSeconds >= 0 && totalDays < 6 {
            return templates[.sixDays] ?? []
        }

        return []
    }
}
