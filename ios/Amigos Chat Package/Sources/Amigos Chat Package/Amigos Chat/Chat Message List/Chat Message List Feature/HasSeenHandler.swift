//
//  IsReadRetriever.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/06/2025.
//

import Foundation

protocol HasSeenHandler {
    func hasSeen(for message: Message) -> Bool
}

struct DefaultsHasSeenHandler: HasSeenHandler {
    func hasSeen(for message: Message) -> Bool {
        return true
    }
}
