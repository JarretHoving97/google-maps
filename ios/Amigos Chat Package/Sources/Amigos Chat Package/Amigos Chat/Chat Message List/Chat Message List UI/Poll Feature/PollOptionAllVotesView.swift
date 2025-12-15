//
//  PollOptionAllVotesView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/08/2025.
//

import SwiftUI

struct LocalPollOptionAllVotesView: View {

    @StateObject var viewModel: PollOptionAllVotesViewModel

    private let pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?

    init(
        viewModel: PollOptionAllVotesViewModel,
        pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.pollOptionAllVotesViewBuilder = pollOptionAllVotesViewBuilder
    }

    var body: some View {
        ScrollView {
            PollOptionResultsView(
                poll: viewModel.poll,
                option: viewModel.option,
                votes: viewModel.pollVotes,
                onVoteAppear: viewModel.onAppear(vote:),
                pollOptionAllVotesViewBuilder: pollOptionAllVotesViewBuilder
            )
        }
    }
}
