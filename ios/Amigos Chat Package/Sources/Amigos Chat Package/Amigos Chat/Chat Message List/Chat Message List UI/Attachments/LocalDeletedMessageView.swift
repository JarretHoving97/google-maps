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
                Text(tr("message.deleted-message-placeholder"))
                    .font(.caption)
                    .italic()
                    .foregroundColor(isSentByCurrentUser ? .white : Color(.darkGray))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(isSentByCurrentUser ? Color(.purple).opacity(0.75) : Color(.greyLight).opacity(0.75)))
            .cornerRadius(12)
            .accessibilityIdentifier("DeletedMessageText")

            if isSentByCurrentUser {
                HStack {
                    if isRightAligned {
                        Spacer()
                    }
                }
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

    LocalDeletedMessageView(
        isRightAligned: false,
        isSentByCurrentUser: false
    )
}
