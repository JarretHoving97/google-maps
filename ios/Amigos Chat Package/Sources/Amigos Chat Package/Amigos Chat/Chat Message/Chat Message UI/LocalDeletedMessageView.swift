//
//  DeletedMessageView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 28/01/2025.
//

import Foundation
import SwiftUI

struct LocalDeletedMessageView: View {

    let isRightAligned: Bool
    let isSentByCurrentUser: Bool

    var body: some View {
        VStack(
            alignment: isRightAligned ? .trailing : .leading,
            spacing: 4
        ) {
            HStack(spacing: 6) {
                Text("message.deleted-message-placeholder")
                    .font(.caption)
                    .italic()

                Image(systemName: "trash.fill")
                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 12, height: 12, alignment: .center)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("Grey Light"))
            .foregroundColor(Color(.black.withAlphaComponent(0.8)))
            .cornerRadius(12)
            .accessibilityIdentifier("DeletedMessageText")

            if isSentByCurrentUser {
                HStack {
                    if isRightAligned {
                        Spacer()
                    }
                }
                .foregroundColor(Color(.gray))

            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("DeletedMessageView")
    }
}

#Preview {
    LocalDeletedMessageView(
        isRightAligned: false,
        isSentByCurrentUser: true
    )
}
