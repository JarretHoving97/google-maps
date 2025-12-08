//
//  LayoutMessageType.swift
//  Amigos Chat Package
//
//  Created by Jarret on 12/03/2025.
//

import Foundation

public enum LayoutMessageType: Equatable {
    // system messages
    case anonymous
    // default messages
    case messageWalkthrough(MessageWalkthroughType)

    var rawValue: String {
        switch self {
        case .anonymous:
            return "anonymous"
        case .messageWalkthrough(let type):
            return type.rawValue
        }
    }

    init?(rawValue: String) {
        if rawValue == "anonymous" {
            self = .anonymous
        } else if let childType = MessageWalkthroughType(rawValue: rawValue) {
            self = .messageWalkthrough(childType)
        } else {
            return nil
        }
     }

    static public func == (lhs: LayoutMessageType, rhs: LayoutMessageType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
