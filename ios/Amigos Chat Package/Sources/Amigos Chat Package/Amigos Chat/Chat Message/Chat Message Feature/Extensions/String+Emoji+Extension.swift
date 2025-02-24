//
//  String+EmojioExtension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 19/02/2025.
//

extension String {

    /// Checks whether the string contains an emoji
    var containsEmoji: Bool { contains { $0.isEmoji } }

    /// Checks whether the string only contains emoji
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
}
