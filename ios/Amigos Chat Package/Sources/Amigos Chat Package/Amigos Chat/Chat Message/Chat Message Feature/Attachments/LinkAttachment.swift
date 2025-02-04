//
//  LinkAttachment.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Foundation

public struct LinkAttachment: Equatable, Hashable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}
