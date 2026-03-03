//
//  MessageSuggestionResolver.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/02/2026.
//

import Foundation

public class HostMessageSuggestionResolver: MessageSuggestionsResolver {

    private let calendar: Calendar

    let now: () -> Date

    var templates: [ReminderCategory: [String]]

    public init(
        calendar: Calendar = .current,
        templates: [ReminderCategory: [String]] = [:],
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
        let totalHours = Int(totalSeconds / 3600)

        // 2 days window [2d, 9h]
        if totalHours >= 9 && totalHours < 48 {
            return templates[.fourtyEightHours] ?? []
        }

        // 9h window: [9h, 3h]
        if totalHours >= 3 && totalHours < 9 {
            return templates[.nineHours] ?? []
        }

        // 3h window: [3h, 0h]
        if totalHours >= 0 && totalHours < 3 {
            return templates[.threeHours] ?? []
        }

        return []
    }
}
