//
//  PollResultsView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 28/08/2025.
//

import SwiftUI

struct PollResultsView: View {

    @Environment(\.presentationMode) var presentationMode

    var viewModel: PollResultsViewModel

    var pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?

    private let numberOfItemsShown = 5

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    content
                }
            } else {
                NavigationView {
                    content
                }
            }
        }
        .tint(Color(.purple))
    }

    var content: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                HStack {
                    Text(viewModel.poll.name)
                        .font(.headline)

                    Spacer()
                }
                .padding()
                .withPollsBackground()
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)

                ForEach(viewModel.options, id: \.id) { option in
                    PollOptionResultsView(
                        poll: viewModel.poll,
                        option: option,
                        votes: Array(option.latestVotes.prefix(numberOfItemsShown)),
                        hasMostVotes: viewModel.hasMostVotes(for: option),
                        allButtonShown: option.latestVotes.count > numberOfItemsShown,
                        pollOptionAllVotesViewBuilder: pollOptionAllVotesViewBuilder
                    )
                }
                Spacer()
            }
        }

        .background(Color(.white).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(tr("message.polls.toolbar.results-title"))
                    .bold()
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .customizable()
                        .frame(width: 16, height: 16)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(.purple))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func withPollsBackground() -> some View {
        modifier(PollsBackgroundModifier())
    }
}

private struct PollsBackgroundModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(Color("Grey Light"))
            .cornerRadius(16)
    }
}
