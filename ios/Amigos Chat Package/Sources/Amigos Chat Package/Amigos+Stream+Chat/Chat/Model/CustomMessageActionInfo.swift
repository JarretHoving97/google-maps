//
//  CustomMessageActionInfo.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/11/2025.
//

import Foundation
import StreamChat

public struct CustomMessageActionInfo {
    public let message: ChatMessage
    public let identifier: String

    public init(message: ChatMessage, identifier: String) {
        self.message = message
        self.identifier = identifier
    }
}
