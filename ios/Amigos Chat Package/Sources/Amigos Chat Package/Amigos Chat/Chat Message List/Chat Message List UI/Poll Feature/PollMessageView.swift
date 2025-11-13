//
//  PollMessageViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import SwiftUI

struct PollMessageView: View {

    @State private var pollResultShown: Bool = false

    @State private var endVoteConfirmationShown = false

    @ObservedObject var viewModel: PollMessageViewModel

    private let defaultTextPadding = EdgeInsets(
        top: 12,
        leading: 14,
        bottom: 12,
        trailing: 14
    )

    private let pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?

    init(viewModel: PollMessageViewModel, pollOptionAllVotesViewBuilder: PollOptionAllVotesViewBuilder?) {
        self.viewModel = viewModel
        self.pollOptionAllVotesViewBuilder = pollOptionAllVotesViewBuilder
    }

    private var bubbleResolvedModifier: ResolvedViewModifier {
        return ResolvedViewModifier(
            MessageBubbleViewModifier(
                contentInsets: defaultTextPadding,
                isSentByCurrentUser: viewModel.isSentByCurrentUser,
                hidden: false,
                shape: BubbleShape(cornerRadius: 16)
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            options

            divider

            seeVotesButton

        }
        .frame(maxWidth: .messageWidth)
        .modifier(bubbleResolvedModifier)
    }

    private var header: some View {

        VStack(alignment: .leading, spacing: 4) {
            Group {
                Text(viewModel.poll.name)
                    .font(Font.headline)

                Text(viewModel.subTitleText)
                    .font(.caption1)
            }
            .foregroundStyle(viewModel.isSentByCurrentUser ? Color(.white) : Color(.black))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
    }

    private var options: some View {

        ForEach(viewModel.options, id: \.option.id) { data in
            PollOptionView(
                viewModel: data
            ) { option in
                viewModel.toggleVoteAction(option)
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2),
            value: viewModel.options.map { $0.option.id }
        )
    }

    private var divider: some View {
        Divider()
            .background(viewModel.isSentByCurrentUser ? Color(.grey) : Color(.white))
    }

    private var seeVotesButton: some View {
        Button {
            pollResultShown.toggle()
        } label: {
            Text(tr("message.polls.button.viewResults"))
                .foregroundStyle(viewModel.isSentByCurrentUser ? Color(.white) : Color(.purple))
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.subheadline)
        }
        .fullScreenCover(isPresented: $pollResultShown) {
            PollResultsView(
                viewModel: PollResultsViewModel(viewModel: viewModel),
                pollOptionAllVotesViewBuilder: pollOptionAllVotesViewBuilder
            )
        }
    }
}
