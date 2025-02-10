//
//  CustomUIFacotry.swift
//  Amigos Chat Package
//
//  Created by Jarret on 04/02/2025.
//
import StreamChatSwiftUI
import SwiftUI

extension CustomUIFactory {

    public func makePhotoAttachmentPickerView(
        assets: PHFetchResultCollection,
        onAssetTap: @escaping (AddedAsset) -> Void,
        isAssetSelected: @escaping (String) -> Bool
    ) -> some View {
        CustomAttachmentTypeContainer {
            PhotoAttachmentPickerView(
                assets: assets,
                onImageTap: onAssetTap,
                imageSelected: isAssetSelected
            )
        }
    }
}

/// Container that displays attachment types.
public struct CustomAttachmentTypeContainer<Content: View>: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) private var colors

    @EnvironmentObject var currentChannelInfo: CurrentChannelInfo

    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {

            if !currentChannelInfo.isDirectMessageChannel {
                consentMediaToUseForStoriesView
            } else {
                Color(colors.background)
                    .frame(height: 20)
            }

            content()
                .background(Color(colors.background))
        }
        .background(Color(colors.background1))
        .accessibilityIdentifier("AttachmentTypeContainer")
    }

    private var consentMediaToUseForStoriesView: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                Image(.infoIcon)
                    .foregroundStyle(Color(.purple))
                    .frame(width: 16, height: 16)

                Text(tr("mediapicker.media.used.for.stories.consent.message"))
                    .font(.custom(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "#333333"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, minHeight: 46)
    }
}
