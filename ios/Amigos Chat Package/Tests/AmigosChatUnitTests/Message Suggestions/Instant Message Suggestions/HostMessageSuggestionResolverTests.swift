//
//  HostMessageSuggestionResolverTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/02/2026.
//

import Testing
import Foundation
import Amigos_Chat_Package

struct HostMessageSuggestionResolverTests: MessageSuggestionTestSpecs {

    @Test func doesNotResolveSuggestionsOutsideWindow() {
        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 10),
            pastOffset: DateComponents(hour: -1),
            makeSUT: makeSUT
        )
    }

    @Test func doesNotResolveSuggestionsAtWindowBoundaries() {
        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 2),
            pastOffset: DateComponents(),
            makeSUT: makeSUT
        )
    }

    @Test func resolvesSuggestionsJustWithinTimeWindow() {
        assertSuggestionsAreNotEmptyAtTimeWindow(
            offSet: DateComponents(day: 1, hour: 23, minute: 59, second: 59),
            makeSUT: makeSUT
        )
    }

    @Test func activatesExpectedCategoryForEachTimeWindow() {
        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(hour: 48, second: -1), .fourtyEightHours),
                (DateComponents(hour: 9, second: -1), .nineHours),
                (DateComponents(hour: 3, second: -1), .threeHours)
            ],
            expectedTemplates: instantMessageTemplates,
            makeSUT: makeSUT
        )
    }

    @Test func resolvesSuggestionsAtAllWindowBoundaries() {
        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(hour: 48, second: -1), .fourtyEightHours),
                (DateComponents(hour: 9), .fourtyEightHours),
                (DateComponents(hour: 8, second: 59), .nineHours),
                (DateComponents(hour: 3), .nineHours),
                (DateComponents(hour: 2, second: 59), .threeHours)
            ],
            expectedTemplates: instantMessageTemplates,
            makeSUT: makeSUT
        )
    }

    // MARK: Helpers
    private func makeSUT(fixedNow: Date) -> HostMessageSuggestionResolver {
        return HostMessageSuggestionResolver(templates: instantMessageTemplates, now: { fixedNow })
    }

    private var instantMessageTemplates: [ReminderCategory: [String]] = [
        .fourtyEightHours: [
            "instant message host 1",
            "instant message host 2"
        ],
        .nineHours: [
            "instant message host 3",
            "instant message host 4"
        ],
        .threeHours: [
            "instant message host 5",
            "instant message host 5"
        ]
    ]
}
