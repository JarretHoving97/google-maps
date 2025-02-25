//
//  ViewFactory+makeCustomAttachmentViewType+Extension.swift
//  App
//
//  Created by Jarret Hoving on 26/11/2024.
//
import StreamChat
import StreamChatSwiftUI
import SwiftUI

extension CustomUIFactory {

    public typealias CustomAttachmentViewType = CustomShareLocationMessageView<CustomUIFactory>

    public func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> CustomAttachmentViewType {
        CustomShareLocationMessageView(
            for: message,
            factory: self,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }
}
