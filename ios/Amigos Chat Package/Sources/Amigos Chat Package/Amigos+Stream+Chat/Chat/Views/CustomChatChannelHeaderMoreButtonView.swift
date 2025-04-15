//
//  CustomChatChannelHeaderMoreButtonView.swift
//  App
//
//  Created by Jarret on 18/12/2024.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

struct CustomChatChannelHeaderMoreButtonView: View {

    var onMoreTapped: (() -> Void)

    public let channel: ChatChannel

    var body: some View {
        HeaderButtonView(iconSystemName: "ellipsis", leading: false) {
            resignFirstResponder()
            onMoreTapped()
        }
    }
}
