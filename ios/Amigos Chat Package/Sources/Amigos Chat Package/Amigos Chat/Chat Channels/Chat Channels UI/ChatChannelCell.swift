//
//  ChatChannelCell.swift
//  Amigos Chat Package
//
//  Created by Jarret on 31/07/2025.
//

import SwiftUI

 public struct ChatChannelCell: View {

    @ObservedObject var viewModel: ChatChannelCellViewModel

     private var onTap: (() -> Void)

     init(viewModel: ChatChannelCellViewModel, onTap: @escaping (() -> Void) = {}) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) { content }
    }

     private var content: some View {
         HStack(spacing: 8) {

             avatarView()

             HStack(alignment: .center, spacing: 20) {

                 VStack(alignment: .leading, spacing: 2) {

                     messageTitleLabel

                     subTitleLabel
                 }

                 Spacer()

                 lastMessageDateLabel
             }

         }
         .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
         .background(Color(.white))
         .contentShape(Rectangle())
     }
}

// MARK: Views
extension ChatChannelCell {

    @ViewBuilder
    private func avatarView() -> some View {

        HStack(spacing: 6) {

            ZStack(alignment: .topLeading) {

                switch viewModel.relatedConceptType {

                case .activity, .mixer:
                    CustomActivityImageView(image: viewModel.image)

                case .community:
                    CommunityChatImageView(image: viewModel.image)

                case .standard:
                    AvatarView(image: viewModel.image)
                }
            }
        }
    }

    var unreadCountBadge: some View {
        Text(viewModel.unreadLabel)
            .lineLimit(1)
            .foregroundColor(.white)
            .font(.caption2)
            .frame(width: viewModel.unreadMessages < 10 ? 18 : nil, height: 18)
            .padding(.horizontal, viewModel.unreadMessages < 10 ? 0 : 6)
            .background(Color(.orange))
            .cornerRadius(9)
            .accessibilityIdentifier("UnreadIndicatorView")
    }

    private var messageTitleLabel: some View {

        Text(viewModel.name)
            .lineLimit(1)
            .font(.headline)
            .foregroundColor(Color(.black))
    }

    private var subTitleLabel: some View {
        Text(viewModel.subtitle)
            .lineLimit(1)
            .foregroundColor(Color(.greyDark))
            .font(.caption2)
    }

    private var lastMessageDateLabel: some View {
        VStack(alignment: .trailing, spacing: 4) {
            unreadCountBadge
                .hidden(viewModel.isRead)

            HStack {
                if viewModel.showReadIndicator {
                    ReadIndicatorView(viewModel: viewModel.readIndicatorViewData)
                        .frame(width: 10, height: 10, alignment: .leading)
                }

                VStack(alignment: .trailing) {
                    Text(viewModel.lastMessageDate ?? "")
                        .font(.caption2)
                        .foregroundStyle(Color(.greyDark))
                }
            }
        }
    }
}

#Preview {
    ChatChannelCell(
        viewModel: ChatChannelCellViewModel(
            channel: LocalChannel(
                id: UUID().uuidString,
                name: "Daisy",
                imageURL: nil,
                lastMessageAt: Date(),
                subtitleText: "Hoe is het met je?",
                otherUser: LocalChatChannelMember(
                    id: UUID().uuidString,
                    name: "Daisy",
                    imageURL: ImageURLExamples.Community.coverURL
                ),
            ),
            name: "Party",
            image: UIImage()

        )
    )
}

#Preview {
    ChatChannelCell(
        viewModel: ChatChannelCellViewModel(
            channel: LocalChannel(
                id: UUID().uuidString,
                name: "Party",
                imageURL: ImageURLExamples.Interests.coffeeURL,
                lastMessageAt: Date(),
                subtitleText: "Meet me at the park",
            ),
            name: "Party",
            image: UIImage()
        )
    )
}

#Preview {
    ChatChannelCell(
        viewModel: ChatChannelCellViewModel(
            channel: LocalChannel(
                id: UUID().uuidString,
                name: "Bar marathon",
                imageURL: ImageURLExamples.Interests.coffeeURL,
                lastMessageAt: Date(),
                unreadCount: LocalChannelUnreadCount(
                    messages: 4,
                    mentions: 0
                ),
                subtitleText: "Ilon: Meet me at the park"
            ),
            name: "Party",
            image: UIImage()
        )
    )
}
