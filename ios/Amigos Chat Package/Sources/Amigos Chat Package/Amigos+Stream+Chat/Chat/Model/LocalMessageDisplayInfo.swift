//
//  LocalMessageDisplayingInfo.swift
//  Amigos Chat Package
//
//  Created by Jarret on 15/10/2025.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

/// replica of Streamchats `MessageDisplayInfo`
/// With `pollViewData` included.
public struct LocalMessageDisplayInfo {
    public let message: ChatMessage
    public let frame: CGRect
    public let contentWidth: CGFloat
    public let isFirst: Bool
    public var showsMessageActions: Bool = true
    public var showsBottomContainer: Bool = true
    public var keyboardWasShown: Bool = false

    public var pollViewData: PollMessageViewModel?

    public init(
        message: ChatMessage,
        frame: CGRect,
        contentWidth: CGFloat,
        isFirst: Bool,
        showsMessageActions: Bool = true,
        showsBottomContainer: Bool = true,
        keyboardWasShown: Bool = false,
        pollViewData: PollMessageViewModel?
    ) {
        self.message = message
        self.frame = frame
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        self.showsMessageActions = showsMessageActions
        self.keyboardWasShown = keyboardWasShown
        self.showsBottomContainer = showsBottomContainer
        self.pollViewData = pollViewData
    }
}
