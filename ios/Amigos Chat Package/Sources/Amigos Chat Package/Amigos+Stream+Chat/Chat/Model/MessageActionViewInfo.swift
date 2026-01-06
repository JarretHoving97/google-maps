//
//  MessageActionViewInfo.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/11/2025.
//

import Foundation
import StreamChat

/// view info needed to generate message actions
public struct MessageActionViewInfo {
    public let message: ChatMessage
    public let isInthread: Bool
}
