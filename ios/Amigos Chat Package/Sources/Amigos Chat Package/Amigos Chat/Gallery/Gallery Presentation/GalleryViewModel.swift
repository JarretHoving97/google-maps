//
//  GalleryViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 31/01/2025.
//

import SwiftUI

class GalleryViewModel: ObservableObject {

    @Published var showSelectedState: Bool = false

    @Published var gridShown: Bool = false

    @Published var selected: Int

    @Published var loadedImages = [Int: UIImage]()

    @Published var selectedIndices: [Int] = []

    @Published var downloading: Bool = false

    @Published var presentActivitySheet: Bool = false

    @Published var shareableContent = [Any]()

    @Binding var isShown: Bool

    let author: LocalUser

    let attachments: [MediaAttachment]

    init(isShown: Binding<Bool>, attachments: [MediaAttachment], author: LocalUser, selected: Int = 0) {
        self.attachments = attachments
        self.author = author
        self.selected = selected
        _isShown = isShown
    }

    func select(index: Int) {
        if !selectedIndices.contains(index) {
            selectedIndices.append(index)
        } else {
            selectedIndices.removeAll { $0 == index }
        }
    }

    func toggleSelectAllAttachments() {
        if selectedIndices.count == attachments.count {
            selectedIndices.removeAll()
        } else {
            selectedIndices = attachments.indices.map {$0}
        }
    }

    func downloadSelectedAttachments() async {
        Task { @MainActor in
            downloading = true
        }

        let downloadedAttachmentsActor = DownloadedAttachmentsActor()
        let selectedAttachments = selectedIndices.map { attachments[$0] }

        await withTaskGroup(of: Void.self) { group in
            for attachment in selectedAttachments {
                group.addTask {
                    do {
                        let data = try await attachment.download()
                        await downloadedAttachmentsActor.append(data: data)
                    } catch {
                        print("Error downloading attachment: \(String(describing: error))")
                    }
                }
            }
        }
        let downloadedAttachments = await downloadedAttachmentsActor.getAttachments()

        Task { @MainActor in
            downloading = false
            shareableContent = downloadedAttachments
            presentActivitySheet.toggle()
        }
    }
}

// MARK: Labels
extension GalleryViewModel {

    var selectAttachmentsLabel: String {
        return Localized.Gallery.selectTitle
    }

    var selectAllItemsLabel: String {
        selectedIndices.count == attachments.count ? Localized.Gallery.deselectAllButtonLabel : Localized.Gallery.selectAllButtonLabel
    }

    var selectedItemsLabel: String {
        let selectedAttachments = selectedIndices
            .map { attachments[$0] }
            .map { $0.type }
            .map { $0.toTranslatableType() }

        return Localized.Gallery.attachmentsSelectedLabel(attachments: selectedAttachments)
    }

    var doneLabel: String {
        return Localized.Gallery.doneTrailingButtonLabel
    }
}

// MARK: Actors
extension GalleryViewModel {

    actor DownloadedAttachmentsActor {
        private var attachments = [Any]()

        func append(data: Any) {
            attachments.append(data)
        }

        func getAttachments() -> [Any] {
            return attachments
        }
    }
}
