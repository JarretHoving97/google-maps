//
//  LocalToken+StreamToken+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 10/01/2025.
//

import StreamChat

public extension LocalToken {

    func toStreamChatToken() throws -> Token {
        return try Token(rawValue: token)
    }
}
