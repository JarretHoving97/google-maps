//
//  PollOptionResultsView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 02/09/2025.
//

import SwiftUI

struct PollOptionResultsView: View {

    var poll: LocalPoll
    var option: LocalPollOption
    var votes: [LocalPollVote]
    var hasMostVotes: Bool = false
    var allButtonShown = false
    var onVoteAppear: ((LocalPollVote) -> Void)?
    var pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?

    init(
        poll: LocalPoll,
        option: LocalPollOption,
        votes: [LocalPollVote],
        hasMostVotes: Bool = false,
        allButtonShown: Bool = false,
        onVoteAppear: ((LocalPollVote) -> Void)? = nil,
        pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?
    ) {
        self.poll = poll
        self.option = option
        self.votes = votes
        self.hasMostVotes = hasMostVotes
        self.allButtonShown = allButtonShown
        self.onVoteAppear = onVoteAppear
        self.pollOptionAllVotesViewBuilder = pollOptionAllVotesViewBuilder
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(option.text)
                    .font(.subheadline)
                Spacer()
                if hasMostVotes {
                    Image(systemName: "trophy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 12)
                }
                Text(tr("message.polls.votes", (poll.voteCountsByOption?[option.id] ?? 0)))
                    .font(.caption1)
            }
            .padding(.horizontal)

            if poll.voteCountsByOption?[option.id] ?? 0 > 0 {
                Divider()

                VStack(spacing: 16) {
                    ForEach(votes, id: \.displayId) { vote in
                        HStack {
                            if poll.votingVisibility != .anonymous {
                                AvatarView(imageUrl: vote.user?.imageUrl, size: 24)
                            }

                            Text(vote.user?.name ?? tr("message.polls.unknown-vote-author"))
                                .font(.body)
                            Spacer()
                            PollDateIndicatorView(date: vote.createdAt)
                        }
                        .onAppear {
                            onVoteAppear?(vote)
                        }
                    }
                }
                .padding(.horizontal)
            }

            if allButtonShown {
                Divider()

                NavigationLink {
                    PollAllOptionsHostingView(
                        poll: poll,
                        option: option,
                        builder: pollOptionAllVotesViewBuilder
                    )
                } label: {
                    Text(tr("message.polls.button.show-all"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.subheadline)
                }
            }
        }
        .padding(.vertical)
        .withPollsBackground()
        .padding(.horizontal)
    }
}

extension LocalPollVote {

    var displayId: String {
        "\(id)-\(optionId ?? user?.id ?? "")-\(pollId)"
    }
}
