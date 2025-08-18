import SwiftUI
import SDWebImageSwiftUI
import StreamChatSwiftUI

/// View representing the user's avatar.
public struct CustomActivityImageView: View {
    var url: URL?
    var size: CGSize = .defaultAvatarSize

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(.orange))
                .frame(width: size.width, height: size.height)

            WebImage(url: url)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 18, alignment: .center)
        }
    }
}
