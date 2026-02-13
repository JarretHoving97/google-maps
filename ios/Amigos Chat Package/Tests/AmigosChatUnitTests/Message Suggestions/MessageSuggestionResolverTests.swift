//
//  MessageSuggestionResolverTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/02/2026.
//

import Testing
import Foundation
import Amigos_Chat_Package

struct MessageSuggestionStoreTests {

    @Test func doesNotResolveSuggestionsOutsideWindow() {
        let now = Date()
        let sut = makeSUT(fixedNow: now)
        // Event far in the future (e.g., 10 days) -> outside window
        let eventTenDaysFromNow = Calendar.current.date(byAdding: .day, value: 10, to: now)!
        let eventOneHourBeforeNow = Calendar.current.date(byAdding: .hour, value: -1, to: now)!

        let messageSuggestionsFuture = sut.resolve(for: eventTenDaysFromNow)
        #expect(messageSuggestionsFuture.isEmpty)

        let messageSuggestionPast = sut.resolve(for: eventOneHourBeforeNow)
        #expect(messageSuggestionPast.isEmpty)
    }

    @Test func doesNotResolveSuggestionsAtWindowBoundaries() {
        let now = Date()
        let sut = makeSUT(fixedNow: now)

        let eventFiveDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: now)
        // exact 2 days is not within the 48 hours range
        let messageSuggestionsFuture = sut.resolve(for: eventFiveDaysFromNow!)
        #expect(messageSuggestionsFuture.isEmpty)

        // exact now is past the message suggestion time range
        let messageSuggestions = sut.resolve(for: now)
        #expect(messageSuggestions.isEmpty)
    }

    @Test func resolvesSuggestionsJustWithinFiveDayWindow() {
        let now = Date()
        let sut = makeSUT(fixedNow: now)

        // exactly one second within 48 hours
        var comps = DateComponents()
        comps.day = 1
        comps.hour = 23
        comps.second = 59
        let eventWithinFourtyEightHoursFromNow = Calendar.current.date(byAdding: comps, to: now)!

        let messageSuggestionsFuture = sut.resolve(for: eventWithinFourtyEightHoursFromNow)
        #expect(!messageSuggestionsFuture.isEmpty)
    }

    @Test func activatesExpectedCategoryForEachTimeWindow() {
        let now = Date()
        let sut = makeSUT(fixedNow: now)

        let event48h = Calendar.current.date(byAdding: .hour, value: 48, to: now)!.addingTimeInterval(-1)
        expectActiveCategory(sut, eventDate: event48h, expectedCategory: .fourtyEightHours)

        // 9h window
        let event9h = Calendar.current.date(byAdding: .hour, value: 9, to: now)!.addingTimeInterval(-1)
        expectActiveCategory(sut, eventDate: event9h, expectedCategory: .nineHours)

        // 3h window
        let event3h = Calendar.current.date(byAdding: .hour, value: 3, to: now)!.addingTimeInterval(-1)
        expectActiveCategory(sut, eventDate: event3h, expectedCategory: .threeHours)
    }

    @Test func resolvesSuggestionsAtAllWindowBoundaries() {
        let now = Date()
        let sut = makeSUT(fixedNow: now)

        let at48Hours = Calendar.current.date(byAdding: .day, value: 2, to: now)!
        let resolvedAt48 = sut.resolve(for: at48Hours)
        let justUnder48Hours = at48Hours.addingTimeInterval(-1)

        #expect(resolvedAt48.isEmpty)
        expectActiveCategory(sut, eventDate: justUnder48Hours, expectedCategory: .fourtyEightHours)

        let at9Hours = Calendar.current.date(byAdding: .hour, value: 9, to: now)!
        let justUnder9Hours = at9Hours.addingTimeInterval(-1)

        expectActiveCategory(sut, eventDate: at9Hours, expectedCategory: .fourtyEightHours)
        expectActiveCategory(sut, eventDate: justUnder9Hours, expectedCategory: .nineHours)

        let at3Hours = Calendar.current.date(byAdding: .hour, value: 3, to: now)!
        let justUnder3Hours = at3Hours.addingTimeInterval(-1)

        expectActiveCategory(sut, eventDate: at3Hours, expectedCategory: .nineHours)
        expectActiveCategory(sut, eventDate: justUnder3Hours, expectedCategory: .threeHours)
    }

    // MARK: Helpers

    private func makeSUT(fixedNow: Date) -> MessageSuggestionResolver {
        return MessageSuggestionResolver(templates: templates, now: { fixedNow })
    }

    private func expectMessageSuggestions(_ actual: [String], equals expected: [String], fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
        #expect(actual == expected, "Expected suggestions to equal \(expected) but got \(actual)", sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column))
    }

    private func expectActiveCategory(_ sut: MessageSuggestionResolver, eventDate: Date, expectedCategory: ReminderCategory, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
        let resolved = sut.resolve(for: eventDate)
        let expected = templates[expectedCategory] ?? []
        expectMessageSuggestions(resolved, equals: expected, fileID: fileID, filePath: filePath, line: line, column: column)
    }

    private var templates: [ReminderCategory: [String]] = [
        .fourtyEightHours: [
            "It's almost time. build anticipation",
            "Share what to expect tomorrow"
        ],
        .nineHours: [
            "Friendly reminder for later today",
            "Give the group a quick nudge"
        ],
        .threeHours: [
            "Final checklist before you meet",
            "Share a short summary and details"
        ]
    ]
}
