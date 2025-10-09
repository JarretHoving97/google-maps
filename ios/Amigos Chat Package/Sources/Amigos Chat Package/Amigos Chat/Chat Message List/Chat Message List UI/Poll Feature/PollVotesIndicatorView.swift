//
//  PollVotesIndicatorView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 26/08/2025.
//

import SwiftUI

struct PollVotesIndicatorView: View {

    let isSentByCurrentUser: Bool
    let optionVotes: Int
    let maxVotes: Int

    private let height: CGFloat = 8

    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.black).opacity(0.1))
                    .frame(width: reader.size.width, height: height)

                RoundedRectangle(cornerRadius: 8)
                    .fill(isSentByCurrentUser ? Color(.white) : Color(.purple))
                    .frame(width: reader.size.width * ratio, height: height)
            }
        }
        .frame(height: height)
    }

    var ratio: CGFloat {
        CGFloat(optionVotes) / CGFloat(max(maxVotes, 1))
    }
}
