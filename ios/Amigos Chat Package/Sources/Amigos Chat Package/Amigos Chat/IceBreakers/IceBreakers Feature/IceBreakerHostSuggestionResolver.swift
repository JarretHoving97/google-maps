//
//  IceBreakerHostSuggestionResolver.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2026.
//

import Foundation

public enum IceBreakerHostSuggestionCategory: String {
    case fiveDays
}

public class IceBreakerHostSuggestionResolver: MessageSuggestionsResolver {

    private let calendar: Calendar

    let now: () -> Date

    private let templates: [IceBreakerHostSuggestionCategory: [String]]

    public init(
        calendar: Calendar = .current,
        templates: [IceBreakerHostSuggestionCategory: [String]] = [:],
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
        if totalSeconds >= 0 && totalDays < 5 {
            return templates[.fiveDays] ?? []
        }

        return []
    }
}
