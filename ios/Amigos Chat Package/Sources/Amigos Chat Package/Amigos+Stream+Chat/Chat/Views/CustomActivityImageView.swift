import SwiftUI
import SDWebImageSwiftUI
import StreamChatSwiftUI

/// View representing the user's avatar.
public struct CustomActivityImageView: View {
    var image: AmiImage
    var size: CGSize = .defaultAvatarSize

    init(image: AmiImage, size: CGSize = CGSize.avatarThumbnailSize) {
        self.image = image
        self.size = size
    }

    init(url: URL?, size: CGSize = CGSize.avatarThumbnailSize) {
        self.image = .url(url)
        self.size = size
    }

    init(uiImage: UIImage, size: CGSize = CGSize.avatarThumbnailSize) {
        self.image = .uiImage(uiImage)
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(.orange))
                .frame(width: size.width, height: size.height)

            AmiImageView(image: image)
                .scaledToFit()
                .frame(maxWidth: 18, alignment: .center)
        }
    }
}
