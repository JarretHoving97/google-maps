//
//  LocalVotingVisibility.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/08/2025.
//

import Foundation

/// Represents the visibility of votes in a poll.
public struct LocalVotingVisibility: RawRepresentable, Equatable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Votes are public and can be seen by everyone.
    public static let `public` = Self(rawValue: "public")
    /// Votes are anonymous and cannot be attributed to individual users.
    public static let anonymous = Self(rawValue: "anonymous")
}
