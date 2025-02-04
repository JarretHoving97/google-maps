//
//  Stream+AttachmentUploading+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/01/2025.
//

import StreamChat

/// Map Steam's object to our own inject
extension AttachmentUploadingState {

    func toLocalType() -> UploadingState {

        var state: LocalState {

            switch self.state {

            case .unknown:
                return .unknown

            case .pendingUpload:
                return .pendingUpload

            case .uploading(progress: let progress):
                return .uploading(progress: progress)

            case .uploadingFailed:
                return .uploadingFailed

            case .uploaded:
                return.uploaded
            }
        }

        return UploadingState(localFileURL: localFileURL, state: state)
    }
}
