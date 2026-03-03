//
//  ExpectationHelpers.swift
//  Amigos Chat Package
//
//  Created by Jarret on 06/02/2026.
//

import Foundation
import Amigos_Chat_Package
import Testing

func expectMessageSuggestions(_ actual: [String], equals expected: [String], fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
    #expect(actual == expected, "Expected suggestions to equal \(expected) but got \(actual)", sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column))
}

func expectActiveCategory<Category: Hashable>(
    _ sut: MessageSuggestionsResolver,
    eventDate: Date,
    expectedCategory: Category,
    expectedTemplates: [Category: [String]],
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column
) {
    let resolved = sut.resolve(for: eventDate)
    let expected = expectedTemplates[expectedCategory] ?? []
    expectMessageSuggestions(
        resolved,
        equals: expected,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}
