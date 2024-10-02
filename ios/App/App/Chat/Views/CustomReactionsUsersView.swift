import StreamChat
import SwiftUI
import StreamChatSwiftUI
import SDWebImageSwiftUI

/// View displaying users who have reacted to a message.
struct CustomReactionsUsersSheetView: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient
    
    @Binding var isPresented: Bool
    
    @ObservedObject var viewModel: ReactionsOverlayViewModel
    
    public init(
        isPresented: Binding<Bool>,
        viewModel: ReactionsOverlayViewModel
    ) {
        _isPresented = isPresented
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(tr("reaction.authors.number-of-reactions", viewModel.message.totalReactionsCount))
                .lineLimit(1)
                .padding(.horizontal, 16)
                .font(fonts.title)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.message.latestReactions), id: \.id) { reaction in
                        
                        AmiReactionRow(reaction: reaction)
                            .onTapGesture {
                                if reaction.author.id == chatClient.currentUserId {
                                    viewModel.reactionTapped(reaction.type)
                                }
                            }
                    }
                }
                .accessibilityIdentifier("ReactionsUsersView")
            }
        }
        .padding(.top, 24)
    }
}

struct AmiReactionRow: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient
    
    public var reaction: ChatMessageReaction
    
    var body: some View {
        HStack(spacing: 12) {
            WebImage(url: reaction.author.imageURL)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 36, alignment: .center)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 0) {
                if let name = reaction.author.name {
                    Text(name)
                        .lineLimit(1)
                        .font(fonts.subheadline)
                }
                
                if reaction.author.id == chatClient.currentUserId {
                    Text("custom.reactions.tapToRemove")
                        .font(fonts.caption2)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            }
            
            Spacer()
            
            if let image = images.availableReactions[reaction.type]?.smallIcon {
                CustomReactionImageView(image: image)
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
    }
}

/// View displaying the reaction image.
struct CustomReactionImageView: View {

    @Injected(\.colors) private var colors

    var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
}
