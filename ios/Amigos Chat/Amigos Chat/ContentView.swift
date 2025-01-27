//
//  ContentView.swift
//  Amigos Chat
//
//  Created by Jarret on 06/01/2025.
//

import SwiftUI

struct ContentView: View {

    public let apiKeyString = "zcgvnykxsfm8"
    public let applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoAppSwiftUI"
    public let currentUserIdRegisteredForPush = "currentUserIdRegisteredForPush"

    var viewModel: ChatChannelsViewModel

    init(viewModel: ChatChannelsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            viewModel.loadChannels()
        }
    }
}

#Preview {
    ContentView(viewModel: ChatChannelsViewModel(loader: nil))
}
