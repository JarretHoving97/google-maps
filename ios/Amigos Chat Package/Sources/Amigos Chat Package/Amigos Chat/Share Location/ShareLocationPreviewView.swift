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
    @State private var presentShareSheet: Bool = false
    @StateObject var viewModel: ShareLocationViewPreviewViewModel

    private var onCustomAttachmentTap: (Attachment) -> Void

    public init(
        username: String,
        addedCustomAttachments: [Attachment],
        onCustomAttachmentTap: @escaping (Attachment) -> Void
    ) {
        self.onCustomAttachmentTap = onCustomAttachmentTap
        _viewModel = StateObject(wrappedValue: ShareLocationViewPreviewViewModel(
            username: username,
            addedCustomAttachments: addedCustomAttachments
        ))
    }

    public var body: some View {

        VStack {
            usersLocationView
                .onTapGesture {
                    presentShareSheet.toggle()
                }
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )

        .shareLocationDialog(
            isPresented: $presentShareSheet,
            title: viewModel.dialogTitle,
            latitude: viewModel.location?.latitudeDouble ?? 0,
            longitude: viewModel.location?.longitudeDouble ?? 0
        )
    }

    private var usersLocationView: some View {

        VStack(spacing: 0) {
            ZStack {
                Color(.purple)
                Image(systemName: "map")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)

            }
            .frame(height: 60)
            ZStack {
                Color(uiColor: .white)
                HStack {
                    Text(viewModel.shareUserLocationTitle)
                        .lineLimit(1)
                        .font(.caption1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(.chevronRight)
                        .foregroundStyle(Color(.purple))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}
