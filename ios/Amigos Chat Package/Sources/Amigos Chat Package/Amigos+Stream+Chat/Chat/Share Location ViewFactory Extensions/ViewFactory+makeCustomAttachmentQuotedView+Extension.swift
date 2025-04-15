//
//  ViewFactory+makeCustomAttachmentQuotedView+Extension.swift
//  App
//
//  Created by Jarret on 10/12/2024.
//

import StreamChatSwiftUI
import StreamChat
import SwiftUI

extension CustomUIFactory {

    public func makeCustomAttachmentQuotedView(for message: ChatMessage) -> some View {
        ShareLocationQuotedView()
    }
}
