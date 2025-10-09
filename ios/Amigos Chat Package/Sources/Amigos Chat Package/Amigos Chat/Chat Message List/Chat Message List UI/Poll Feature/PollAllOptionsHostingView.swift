//
//  PollAllOptionsHostingView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/09/2025.
//

import SwiftUI

/// prevents `LocalPollOptionAllVotesView` initializing and loading before navigation
struct PollAllOptionsHostingView: View {

    let poll: LocalPoll
    let option: LocalPollOption
    var builder: PollOptionAllVotesViewBuilder?

    @State private var view: LocalPollOptionAllVotesView?

    var body: some View {
        ZStack {
            view
        }
        .navigationTitle(option.text)
        .task {
            await MainActor.run {
                view = builder?(poll, option)
            }
        }
    }
}
