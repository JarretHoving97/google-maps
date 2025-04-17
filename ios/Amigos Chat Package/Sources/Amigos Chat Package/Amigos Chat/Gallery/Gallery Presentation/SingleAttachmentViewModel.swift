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

    @Published var image: UIImage?

    @Published var attachmentToShare: LocalFileActivityItemSource?
    @Published var player: AVPlayer?

    var type: MediaAttachmentType {
        return attachment.type
    }

    init(
        author: LocalUser,
        attachment: MediaAttachment,
        image: UIImage? = nil
    ) {
        self.author = author
        self.attachment = attachment
        self.image = image

        Task {
            try? await load()
        }
    }

    @MainActor
    private func load() async throws {
        if case .photo = attachment.type {
            guard image == nil else { return }
            image = try await attachment.imageLoader.loadImageAsync(url: attachment.url, imageCDN: attachment.imageCDN, resize: false, preferredSize: nil)
        }

        if case .video = attachment.type {
            let player = AVPlayer(url: attachment.url)
            player.allowsExternalPlayback = false
            self.player = player

            try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
            player.play()
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
