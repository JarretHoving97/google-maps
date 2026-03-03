//
//  IceBreakersMessageSuggestionResolverTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 06/02/2026.
//

import Testing
import Foundation
import Amigos_Chat_Package

class IceBreakersHostMessageSuggestionResolverTests: MessageSuggestionTestSpecs {

    @Test func doesNotResolveSuggestionsOutsideWindow() {
        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 10),
            pastOffset: DateComponents(hour: -1),
            makeSUT: makeSUT
        )
    }

    @Test func doesNotResolveSuggestionsAtWindowBoundaries() {
        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 5),
            pastOffset: DateComponents(),
            makeSUT: makeSUT
        )
    }

    @Test func resolvesSuggestionsJustWithinTimeWindow() {
        assertSuggestionsAreNotEmptyAtTimeWindow(
            offSet: DateComponents(day: 4, hour: 23, minute: 59, second: 59),
            makeSUT: makeSUT
        )
    }

    @Test func activatesExpectedCategoryForEachTimeWindow() {
        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(day: 4, hour: 23, minute: 59, second: 59), .fiveDays)
            ],
            expectedTemplates: templates,
            makeSUT: makeSUT
        )
    }

    @Test func resolvesSuggestionsAtAllWindowBoundaries() {
        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(day: 4, hour: 23, minute: 59, second: 59), .fiveDays),
                (DateComponents(second: 1), .fiveDays)
            ],
            expectedTemplates: templates,
            makeSUT: makeSUT
        )
    }

    private func makeSUT(fixedNow: Date) -> IceBreakerHostSuggestionResolver {
        IceBreakerHostSuggestionResolver(templates: templates, now: {fixedNow})
    }

    private var templates: [IceBreakerHostSuggestionCategory: [String]] {
        return [
            .fiveDays: [
                "Wat is je favoriete kennismaakdrankje?",
                "Dilemma: ben je vaker een vragensteller of een -beantwoorder?",
                "Dilemma: liever nooit meer alleen zijn, of altijd alleen zijn?",
                "Dilemma: doe je leuke dingen je vaker gepland, of spontaan?",
                "One truth, one lie: deel 1 feitje en 1 leugen met jezelf. Wij gaan raden!"
            ]
        ]
    }
}
