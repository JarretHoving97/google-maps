//
//  ReactionOverlayView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/02/2025.
//

import SwiftUI

// TODO: Implement
///it is functional but needs to be impleneted like we do in `CustomChatChannelMessageListView` with the `onLongPress` closure
struct ReactionsOverlayView: View {

    let viewModel: ReactionsContainerViewModel

    var onReactionTap: (ReactionType) -> Void

    @State var animationStates: [CGFloat]

    init(viewModel: ReactionsContainerViewModel, onReactionTap: @escaping (ReactionType) -> Void) {
        self.viewModel = viewModel
        self.onReactionTap = onReactionTap

        _animationStates = State(
            initialValue: [CGFloat](repeating: 0, count: viewModel.reactions.count)
        )
    }

    var body: some View {

        VStack {
            ReactionsHStack(message: viewModel.message) {
                animatableView
            }
            Spacer()
        }
        .offset(
            x: offsetX,
            y: -20
        )
        .accessibilityElement(children: .contain)
    }

    private var reactionsSize: CGFloat {
        let entrySize = 32
        return CGFloat(viewModel.reactionsProvider.availableReations.count * entrySize)
    }

    private var offsetX: CGFloat {
        let offset = reactionsSize / 3
        return viewModel.message.isSentByCurrentUser ? -offset : offset
    }
}

// MARK: Views
extension ReactionsOverlayView {

    var animatableView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.reactions) { reaction in
                    reactionView(for: reaction)
                }
            }
        }
        .padding(.all, 6)
        .padding(.horizontal, 4)
        .reactionsBubble()
    }

    @ViewBuilder
    func reactionView(
        for reaction: ReactionType,
        useLargeIcons: Bool = false
    ) -> some View {
        if let image = viewModel.getIcon(for: reaction) {
            Button {
                onReactionTap(reaction)
            } label: {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: useLargeIcons ? 25 : 20, height: useLargeIcons ? 27 : 20)
            }
            .background(Color.white.cornerRadius(8))

            .scaleEffect(viewModel.index(for: reaction) != nil ? animationStates[viewModel.index(for: reaction)!] : 1)
            .onAppear {
                guard let index = viewModel.index(for: reaction) else {
                    return
                }

                withAnimation(
                    .interpolatingSpring(
                        stiffness: 170,
                        damping: 8
                    )
                    .delay(0.1 * CGFloat(index + 1))
                ) {
                    animationStates[index] = 1
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("reaction-\(reaction.rawValue)")
        }
    }
}

// MARK: Helper
public struct ReactionsHStack<Content: View>: View {
    var message: Message
    var content: () -> Content

    public init(message: Message, content: @escaping () -> Content) {
        self.message = message
        self.content = content
    }


    public var body: some View {
        HStack {
            if !message.isSentByCurrentUser {
                Spacer()
            }

            content()

            if message.isSentByCurrentUser {
                Spacer()
            }
        }
    }
}

#Preview {
    MessageContainerView(
        viewModel: MessageContainerViewModel(
            message: Message(
                message: "Hold to react.",
                quotedMessage: { Message(message: "Quoted Message") },
                isDeleted: false
            ),
            showsAllInfo: true,
            isDirectMessageChat: false
        ), pollOptionAllVotesViewBuilder: nil
    )
    .frame(maxWidth: .messageWidth)
}
