//
//  MessageSuggestionTestsSpecs.swift
//  Amigos Chat Package
//
//  Created by Jarret on 06/02/2026.
//

import Foundation
import Testing
import Amigos_Chat_Package

protocol MessageSuggestionTestSpecs {
    func doesNotResolveSuggestionsOutsideWindow()
    func doesNotResolveSuggestionsAtWindowBoundaries()
    func resolvesSuggestionsJustWithinTimeWindow()
    func activatesExpectedCategoryForEachTimeWindow()
    func resolvesSuggestionsAtAllWindowBoundaries()
}

extension MessageSuggestionTestSpecs {

    private func assertNoSuggestions(
        for dates: [Date],
        fixedNow: Date,
        makeSUT: (Date) -> any MessageSuggestionsResolver,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let sut = makeSUT(fixedNow)
        dates.forEach { date in
            let suggestions = sut.resolve(for: date)
            #expect(
                suggestions.isEmpty,
                "Expected no suggestions for date \(date) with now=\(fixedNow)",
                sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
            )
        }
    }

    private func assertSuggestions(
        for dates: [Date],
        fixedNow: Date,
        makeSUT: (Date) -> any MessageSuggestionsResolver,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let sut = makeSUT(fixedNow)
        dates.forEach { date in
            let suggestions = sut.resolve(for: date)
            #expect(
                !suggestions.isEmpty,
                "Expected suggestions for date \(date) with now=\(fixedNow)",
                sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
            )
        }
    }

    func assertNoSuggestionsRelative(
        futureOffset: DateComponents,
        pastOffset: DateComponents,
        makeSUT: (Date) -> any MessageSuggestionsResolver,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let fixedNow = Date.now
        let cal = Calendar.current
        let future = cal.date(byAdding: futureOffset, to: fixedNow)!
        let past = cal.date(byAdding: pastOffset, to: fixedNow)!

        assertNoSuggestions(
            for: [future, past],
            fixedNow: fixedNow,
            makeSUT: makeSUT,
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
    }

    func assertSuggestionsAreNotEmptyAtTimeWindow(
        offSet: DateComponents,
        makeSUT: (Date) -> any MessageSuggestionsResolver,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column) {
        let fixedNow = Date.now
        let cal = Calendar.current
        let atWindowOffset =  cal.date(byAdding: offSet, to: fixedNow)!
        assertSuggestions(for: [atWindowOffset], fixedNow: fixedNow, makeSUT: makeSUT)
    }

    func assertExpectedCategoriesAtOffsets<Category: Hashable>(
        offsetsAndCategories: [(DateComponents, Category)],
        expectedTemplates: [Category: [String]],
        makeSUT: (Date) -> any MessageSuggestionsResolver,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let fixedNow = Date.now
        let sut = makeSUT(fixedNow)
        let cal = Calendar.current
        offsetsAndCategories.forEach { (offset, expectedCategory) in
            let date = cal.date(byAdding: offset, to: fixedNow)!
            expectActiveCategory(
                sut,
                eventDate: date,
                expectedCategory: expectedCategory,
                expectedTemplates: expectedTemplates,
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
        }
    }
}
