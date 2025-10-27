//
//  UnsupportedAttachmentView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/10/2025.
//

import SwiftUI

struct UnsupportedAttachmentView: View {

    let viewModel = UnsupportedAttachmentViewModel()

    var body: some View {
        ZStack(alignment: .leading) {
            content
                .multilineTextAlignment(.leading)
                .font(.caption)
                .foregroundStyle(.gray)
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.black.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var content: some View {
        if #unavailable(iOS 17) {
            Text(viewModel.iosVersionMessage)
                .tint(.gray)
        } else {
            if let attributed = viewModel.appUpdateMarkdownAttributedString {
                Text(attributed)
                    .tint(.gray)
            } else {
                Text(viewModel.anUpdateMarkdownRegularString)
                    .font(.caption.bold())
                    .tint(.gray)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        UnsupportedAttachmentView()
    }
    .frame(width: UIScreen.main.bounds.size.width * 0.6)
}
