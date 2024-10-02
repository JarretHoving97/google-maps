import Combine
import Foundation
import StreamChat
import UIKit
import StreamChatSwiftUI

class CustomChannelHeaderLoader: ChannelHeaderLoader {
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    /// The maximum number of images that combine to form a single avatar
    private let maxNumberOfImagesInCombinedAvatar = 4

    /// Prevents image requests to be executed if they failed previously.
    private var failedImageLoads = Set<ChannelId>()

    /// Batches loaded images for update, to improve performance.
    private var scheduledUpdates = Set<ChannelId>()

    /// Context provided utils.
    internal lazy var imageLoader = utils.imageLoader
    internal lazy var imageCDN = utils.imageCDN
    internal lazy var channelAvatarsMerger = utils.channelAvatarsMerger
    internal lazy var channelNamer = utils.channelNamer
    
    private var loadedImages = [ChannelId: UIImage]()
    private let didLoadImage = PassthroughSubject<ChannelId, Never>()
    
    internal lazy var placeholder1 = images.userAvatarPlaceholder1
    
    /// Loads an image for the provided channel.
    /// If the image is not downloaded, placeholder is returned.
    /// - Parameter channel: the provided channel.
    /// - Returns: the available image.
    override func image(for channel: ChatChannel) -> UIImage {
        if let image = loadedImages[channel.cid] {
            return image
        }

        if channel.isDirectMessageChannel {
            let lastActiveMembers = self.lastActiveMembers(for: channel)
            if let otherMember = lastActiveMembers.first, let url = otherMember.imageURL {
                loadChannelThumbnail(for: channel.cid, from: url)
                
                if let name = otherMember.name {
                    return name.toAvatarImage(size: 40)
                }
            }
        }
        
        return placeholder1
    }
    
    // MARK: - private

    private func didFinishedLoading(for cid: ChannelId, image: UIImage) {
        loadedImages[cid] = image
        
        if scheduledUpdates.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self else { return }
                let updates = self.scheduledUpdates
                self.scheduledUpdates.removeAll()
                updates.forEach { self.didLoadImage.send($0) }
            }
        }
        
        scheduledUpdates.insert(cid)
    }
    
    private func loadMergedAvatar(from cid: ChannelId, urls: [URL]) {
        if failedImageLoads.contains(cid) {
            return
        }

        imageLoader.loadImages(
            from: urls,
            placeholders: [],
            loadThumbnails: true,
            thumbnailSize: .avatarThumbnailSize,
            imageCDN: imageCDN
        ) { [weak self] images in
            guard let self = self else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                let image = self.channelAvatarsMerger.createMergedAvatar(from: images)
                DispatchQueue.main.async {
                    if let image = image {
                        self.didFinishedLoading(for: cid, image: image)
                    } else {
                        self.failedImageLoads.insert(cid)
                    }
                }
            }
        }
    }

    private func loadChannelThumbnail(
        for cid: ChannelId,
        from url: URL
    ) {
        if failedImageLoads.contains(cid) {
            return
        }

        imageLoader.loadImage(
            url: url,
            imageCDN: imageCDN,
            resize: true,
            preferredSize: .avatarThumbnailSize
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    self.didFinishedLoading(for: cid, image: image)
                }
            case let .failure(error):
                self.failedImageLoads.insert(cid)
                log.error("error loading image: \(error.localizedDescription)")
            }
        }
    }

    private func lastActiveMembers(for channel: ChatChannel) -> [ChatChannelMember] {
        channel.lastActiveMembers
            .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
            .filter { $0.id != chatClient.currentUserId }
    }
}
