//
//  PollOptionView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import SwiftUI

struct PollOptionView: View {

    let viewModel: PollOptionViewModel
    let castVoteAction: (LocalPollOption) -> Void

    init(
        viewModel: PollOptionViewModel,
        castVoteAction: @escaping (LocalPollOption) -> Void = {_ in }
    ) {
        self.viewModel = viewModel
        self.castVoteAction = castVoteAction
    }
    /// The spacing between the checkbox and the option name.
    /// By default it is 4. For All Options View is 8.
    var checkboxButtonSpacing: CGFloat = 6

    var body: some View {

        HStack(alignment: .center, spacing: checkboxButtonSpacing) {

            if !viewModel.pollIsClosed {
                PollRadioButtonView(
                    isSelected: viewModel.optionVotedByCurrentUser,
                    isSentByCurrentUser: viewModel.isSentByCurrentUser,
                    action: { castVoteAction(viewModel.option) }
                )
                .accessibilityLabel(
                    viewModel.optionVotedByCurrentUser
                    ? tr("message.polls.accessibility.voted")
                    : tr("message.polls.accessibility.not-voted")
                )
                .accessibilityAddTraits(.isButton)
            }

            VStack(spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Group {
                        Text(viewModel.option.text)
                            .font(.caption1)
                            .onTapGesture {
                                guard !viewModel.pollIsClosed else { return }
                                castVoteAction(viewModel.option)
                            }

                        Spacer()

                        HStack(spacing: -8) {
                            ForEach(viewModel.latestVoters.prefix(2)) { user in
                                AvatarView(imageUrl: user.imageUrl, size: 20)
                            }
                        }
                        .frame(height: 24)
                        .opacity(viewModel.showVoters ? 1 : 0)
                        .accessibilityHidden(!viewModel.showVoters)
                        .allowsHitTesting(viewModel.showVoters)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.showVoters)

                        Text(viewModel.votes.description)
                            .font(.footnote)
                            .modifier(NumericTransitionModifier())
                            .animation(
                                .spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2),
                                value: viewModel.latestVoters.count
                            )
                    }
                    .foregroundStyle(viewModel.isSentByCurrentUser ? Color(.white) : Color(.darkText))
                }
                PollVotesIndicatorView(
                    isSentByCurrentUser: viewModel.isSentByCurrentUser,
                    optionVotes: viewModel.votes,
                    maxVotes: viewModel.maxVotes
                )
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2),
                    value: viewModel.latestVoters.count
                )
            }
        }
    }
}

struct NumericTransitionModifier: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .contentTransition(.numericText())
        } else {
            content
        }
    }
}

#Preview {
    PollOptionView(
        viewModel: PollOptionViewModel(
            option: .mockOptions.first!,
            isSentByCurrentUser: false,
            maxVotes: 3,
            votes: 2,
            pollIsClosed: false
        )
    )
    .padding(.horizontal, 20)
}
