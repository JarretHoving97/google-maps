//
//  AttachmentUploadingStateViewModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/01/2025.
//

import SwiftUI

struct AttachmentUploadingStateViewModifier: ViewModifier {
    var uploadState: UploadingState?

    func body(content: Content) -> some View {
        content
            .overlay(
                uploadState != nil ? AttachmentUploadingStateView(uploadingState: uploadState!) : nil
            )
    }
}
