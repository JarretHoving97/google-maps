//
//  ViewFactory+CustomAttachmentPickerView+Extension.swift
//  App
//
//  Created by Jarret Hoving on 25/11/2024.
//

import Photos
import StreamChatSwiftUI
import SwiftUI

extension ViewFactory {

    public typealias AttachmentPickerViewType = CustomAttachmentPickerView<Self>

    public func makeAttachmentPickerView(
        attachmentPickerState: Binding<AttachmentPickerState>,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>?,
        onAssetTap: @escaping (AddedAsset) -> Void,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        isAssetSelected: @escaping (String) -> Bool,
        addedCustomAttachments: [CustomAttachment],
        cameraImageAdded: @escaping (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping () -> Void,
        isDisplayed: Bool,
        height: CGFloat,
        popupHeight: CGFloat
    ) -> CustomAttachmentPickerView<Self> {

        CustomAttachmentPickerView(
            viewFactory: self,
            selectedPickerState: attachmentPickerState,
            filePickerShown: filePickerShown,
            cameraPickerShown: cameraPickerShown,
            addedFileURLs: addedFileURLs,
            onPickerStateChange: onPickerStateChange,
            photoLibraryAssets: photoLibraryAssets,
            onAssetTap: onAssetTap,
            onCustomAttachmentTap: onCustomAttachmentTap,
            isAssetSelected: isAssetSelected,
            addedCustomAttachments: addedCustomAttachments,
            cameraImageAdded: cameraImageAdded,
            askForAssetsAccessPermissions: askForAssetsAccessPermissions,
            isDisplayed: isDisplayed,
            height: height,
            popupHeight: popupHeight
        )
    }
}
