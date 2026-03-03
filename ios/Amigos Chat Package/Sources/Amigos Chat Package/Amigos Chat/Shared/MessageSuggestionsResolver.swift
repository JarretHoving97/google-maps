//
//  MessageSuggestionsProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 05/02/2026.
//

import Foundation

public protocol MessageSuggestionsResolver {
    func resolve(for date: Date) -> [String]
}
