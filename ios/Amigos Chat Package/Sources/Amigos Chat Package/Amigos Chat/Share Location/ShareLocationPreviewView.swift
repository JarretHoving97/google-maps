//
//  ShareLocationPreviewView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 03/02/2025.
//

import SwiftUI
import StreamChatSwiftUI
import CoreLocation

public struct ShareLocationPreviewView: View {

    public typealias Attachment = CustomAttachment

    @ObservedObject var viewModel: ShareLocationViewPreviewViewModel

    private var onCustomAttachmentTap: (Attachment) -> Void

    public init(
        username: String,
        addedCustomAttachments: [Attachment],
        onCustomAttachmentTap: @escaping (Attachment) -> Void
    ) {
        self.onCustomAttachmentTap = onCustomAttachmentTap
        _viewModel = ObservedObject(
            initialValue: ShareLocationViewPreviewViewModel(
                username: username,
                addedCustomAttachments: addedCustomAttachments
            )
        )
    }

    public var body: some View {
        ZStack {
            Color(uiColor: UIColor(resource: .coolerGray))
            HStack {
                Text(viewModel.shareUserLocationTitle)
                    .lineLimit(1)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(.chevronRight)
            }
            .padding()
        }
        .roundWithBorder()
        .frame(height: 60)
        .padding(4)
    }
}
