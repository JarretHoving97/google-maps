//
//  LinkDetectionTextView
//  Amigos Chat Package
//
//  Created by Jarret on 21/02/2025.
//

import SwiftUI

struct LinkDetectionTextView: View {

    @ObservedObject private var viewModel: LinkDetectionTextViewModel

    init(viewModel: LinkDetectionTextViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Text(viewModel.messageText)
            .environment(\.openURL, OpenURLAction { url in
                switch url.scheme?.lowercased() {
                case "http", "https":
                    viewModel.handleLinkTap(url)
                    return .handled
                default:
                    return .systemAction
                }
            })
            .confirmationDialog(
                viewModel.actionSheetDialogTitle,
                isPresented: $viewModel.tappedUrl.toBoolBinding,
                titleVisibility: .visible
            ) {
                Group {
                    Button(viewModel.leaveAppButtonTitle) { viewModel.openURL() }
                    Button(viewModel.cancelButtonTitle, role: .cancel) {}
                }
                .tint(Color(.purple))

            } message: {
                Text(viewModel.tappedUrl?.absoluteString ?? "")
            }
    }
}

#Preview {
    LinkDetectionTextView(
        viewModel: LinkDetectionTextViewModel(
            isSentByCurrentUser: false,
            isModerator: true,
            text: "**Thank you!** Please visit our [website](https://example.com)  \nThis is second line"
        )
    )

    .frame(width: UIScreen.main.bounds.size.width * 0.6)
}
