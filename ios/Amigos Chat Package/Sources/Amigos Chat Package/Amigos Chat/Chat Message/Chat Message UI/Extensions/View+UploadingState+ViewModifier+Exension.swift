//
//  View+UploadingState+ViewModifier+Exension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/01/2025.
//

import SwiftUI

extension View {
    /// Attaches a uploading state indicator.
    /// - Parameters:
    ///  - uploadState: the upload state of the asset.
    ///  - url: the url of the asset.
    public func withUploadingStateIndicator(for uploadState: UploadingState?, url: URL) -> some View {
        modifier(AttachmentUploadingStateViewModifier(uploadState: uploadState))
    }
}
