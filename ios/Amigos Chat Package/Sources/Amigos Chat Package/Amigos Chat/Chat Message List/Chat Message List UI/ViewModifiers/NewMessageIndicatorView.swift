//
//  NewMessageIndicatorView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 12/06/2025.
//

import SwiftUI

public struct NewMessageIndicatorViewModifier: ViewModifier {

    @ObservedObject var viewModel: NewMessageIndicatorViewModel

    init(viewModel: NewMessageIndicatorViewModel) {
        self.viewModel = viewModel
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                VStack(spacing: 0) {
                    newMessageLineView
                    endNewMessageView
                }
                .hidden(!viewModel.show)
            }
    }

    var line: some View {
        VStack {
            Divider()
                .background(Color("Purple"))
        }
    }

    var newMessageLineView: some View {
        HStack(spacing: 20) {

            line

            Text(viewModel.newMessageLabel)
                .fixedSize()
                .font(.subheadline)
                .foregroundColor(Color("Purple"))

            line
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
    }

    var endNewMessageView: some View {
        EmptyView()
            .frame(height: 50)
    }
}

#Preview {
    let firstMessage = Message(id: UUID().uuidString, message: "Hello there!")

    let messages = [firstMessage]

    MessageListView(
        viewModel: MessageListViewModel(
            messageList: messages,
            isDirectMessageChat: true,
            firstUnreadMessageId: nil,
            isReadHandler: DefaultsHasSeenHandler(),
            config: MessageListDisplayConfiguration()
        ),
        scrollDirection: .constant(.up),
        onMessageAppear: { _, _ in },
        pollOptionAllVotesViewBuilder: nil
    )
    .flippedUpsideDown()
    .frame(height: 120)
    .modifier(
        NewMessageIndicatorViewModifier(
            viewModel: NewMessageIndicatorViewModel(
                newMessageStartId: firstMessage.id,
                show: true,
                count: 1
            )
        )
    )
}

extension View {
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
}
