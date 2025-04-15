//
//  SingleAttachmentViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 14/02/2025.
//

import Foundation
import SwiftUI
import AVKit

class SingleAttachmentViewModel: ObservableObject {

    let author: LocalUser
    let attachment: MediaAttachment

    @Published var attachmentToShare: LocalFileActivityItemSource?
    @Published var player: AVPlayer?

    var type: MediaAttachmentType {
        return attachment.type
    }

    init(author: LocalUser, attachment: MediaAttachment) {
        self.author = author
        self.attachment = attachment
        configurePlayer()
    }

    private func configurePlayer() {
        if case .video = attachment.type {
            let player = AVPlayer(url: attachment.url)
            player.allowsExternalPlayback = false
            self.player = player
        }
    }

    @MainActor
    func downloadAttachment() async {
        do {
            let url = try await AttachmentDownloader.downloadShareableActivity(from: attachment)
            attachmentToShare = LocalFileActivityItemSource(url: url)
        } catch {
            print("Failed downloading attachment: \(error.localizedDescription)")
        }
    }
}
