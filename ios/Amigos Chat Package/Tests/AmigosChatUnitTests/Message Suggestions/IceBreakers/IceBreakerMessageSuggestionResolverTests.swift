//
//  IceBreakerMessageSuggestionResolverTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/02/2026.
//

import Testing
import Foundation
import Amigos_Chat_Package

struct IceBreakerMessageSuggestionResolverTests: MessageSuggestionTestSpecs {

    @Test func doesNotResolveSuggestionsOutsideWindow() {
        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 10),
            pastOffset: DateComponents(hour: -1),
            makeSUT: { makeSUT(fixedNow: $0, isHost: false) }
        )

        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 10),
            pastOffset: DateComponents(hour: -1),
            makeSUT: { makeSUT(fixedNow: $0, isHost: true) }
        )
    }

    @Test func doesNotResolveSuggestionsAtWindowBoundaries() {
        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 6),
            pastOffset: DateComponents(),
            makeSUT: { makeSUT(fixedNow: $0, isHost: false) }
        )

        assertNoSuggestionsRelative(
            futureOffset: DateComponents(day: 5),
            pastOffset: DateComponents(),
            makeSUT: { makeSUT(fixedNow: $0, isHost: true) }
        )
    }

    @Test func resolvesSuggestionsJustWithinTimeWindow() {
        assertSuggestionsAreNotEmptyAtTimeWindow(
            offSet: DateComponents(day: 5, hour: 23, minute: 59, second: 59),
            makeSUT: { makeSUT(fixedNow: $0, isHost: false) }
        )

        assertSuggestionsAreNotEmptyAtTimeWindow(
            offSet: DateComponents(day: 4, hour: 23, minute: 59, second: 59),
            makeSUT: { makeSUT(fixedNow: $0, isHost: true) }
        )
    }

    @Test func activatesExpectedCategoryForEachTimeWindow() {
        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(day: 5, hour: 23, minute: 59, second: 59), .sixDays)
            ],
            expectedTemplates: participantTemplates,
            makeSUT: { makeSUT(fixedNow: $0, isHost: false) }
        )

        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(day: 4, hour: 23, minute: 59, second: 59), .fiveDays)
            ],
            expectedTemplates: hostTemplates,
            makeSUT: { makeSUT(fixedNow: $0, isHost: true)}
        )
    }

    @Test func resolvesSuggestionsAtAllWindowBoundaries() {
        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(day: 5, hour: 23, minute: 59, second: 59), .sixDays),
                (DateComponents(second: 1), .sixDays)
            ],
            expectedTemplates: participantTemplates,
            makeSUT: { makeSUT(fixedNow: $0, isHost: false) }
        )

        assertExpectedCategoriesAtOffsets(
            offsetsAndCategories: [
                (DateComponents(day: 4, hour: 23, minute: 59, second: 59), .fiveDays),
                (DateComponents(second: 1), .fiveDays)
            ],
            expectedTemplates: hostTemplates,
            makeSUT: { makeSUT(fixedNow: $0, isHost: true) }
        )
    }

    private func makeSUT(fixedNow: Date, isHost: Bool) -> IceBreakerMessageSuggestionResolver {
        IceBreakerMessageSuggestionResolver(
            isHost: isHost,
            participantResolver: IceBreakerParticipantSuggestionResolver(templates: participantTemplates, now: {fixedNow}),
            hostResolver: IceBreakerHostSuggestionResolver(templates: hostTemplates, now: {fixedNow})
        )
    }
}
