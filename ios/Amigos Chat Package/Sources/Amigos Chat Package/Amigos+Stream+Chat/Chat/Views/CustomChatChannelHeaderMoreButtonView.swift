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

    @EnvironmentObject private var viewModel: ChatChannelListViewModel

    public let channel: ChatChannel

    var body: some View {
        HeaderButtonView(iconSystemName: "ellipsis", leading: false) {
            resignFirstResponder()

            withAnimation {
                viewModel.onMoreTapped(channel: channel)
            }
        }
    }
}
