//
//  Stream+AttachmentDownloading+Uploading+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 27/01/2025.
//

import StreamChat

/// Map Steam's object to our own inject
extension AttachmentDownloadingState {

    func toLocalType() -> DownloadingState {

        var state: LocalDownloadState {
            switch self.state {
            case .downloading(progress: let progress):
                return .downloading(progress: progress)
            case .downloadingFailed:
                return .downloadingFailed
            case .downloaded:
                return .downloaded
            }
        }

        return DownloadingState(localFileURL: localFileURL, state: state)
    }
}
