import SwiftUI

public struct CustomAvatarView: View {
    var avatar: UIImage
    var size: CGSize = .defaultAvatarSize

    public var body: some View {
        Image(uiImage: avatar)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipShape(Circle())
    }
}
