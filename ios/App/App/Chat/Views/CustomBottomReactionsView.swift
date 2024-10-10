import StreamChat
import SwiftUI
import StreamChatSwiftUI

struct CustomBottomReactionsView: View {
    
    @Injected(\.chatClient) var chatClient
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    
    var showsAllInfo: Bool
    var reactionsPerRow: Int
    var onTap: () -> Void
    var onLongPress: () -> Void
    
    @StateObject var viewModel: ReactionsOverlayViewModel
    
    @State var isReactionsUsersSheetPresented = false

    private let reactionSize: CGFloat = 16
    private let cornerRadius: CGFloat = 12
    
    init(
        message: ChatMessage,
        showsAllInfo: Bool,
        reactionsPerRow: Int = 4,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) {
        self.showsAllInfo = showsAllInfo
        self.onTap = onTap
        self.reactionsPerRow = reactionsPerRow
        self.onLongPress = onLongPress
        _viewModel = StateObject(wrappedValue: ReactionsOverlayViewModel(message: message))
    }
    
    var body: some View {
            HStack(spacing: 4) {
                ForEach(reactions, id: \.self) { reaction in
                    HStack(spacing: 2) {
                        if let stringIcon = stringIcon(for: reaction) {
                            Text(stringIcon)
                                .font(.system(size: 12))
                                .minimumScaleFactor(0.5)
                        } else if let imageIcon = imageIcon(for: reaction) {
                            ReactionIcon(icon: imageIcon)
                                .frame(width: reactionSize, height: reactionSize)
                        }
                        
                        if count(for: reaction) > 1 {
                            Text("\(count(for: reaction))")
                                .font(Font.custom(size: 10, weight: ThemeFontWeight.medium))
                                .foregroundStyle(Color("Grey Dark"))
                                .padding(.trailing, 2)
                        }
                    }
                    .animation(nil)
                    .onTapGesture {
                        viewModel.reactionTapped(reaction)
                    }
                }
            }
            .padding(.all, 4)
            .modifier(
                BubbleModifier(
                    corners: .allCorners,
                    backgroundColors: [Color(colors.background1)],
                    cornerRadius: cornerRadius
                )
            )
            .padding(.top, -14)
            .padding(.horizontal, 4)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.2, maximumDistance: 20).onEnded { _ in
                    isReactionsUsersSheetPresented = true
                }
            )
            .chatSheetPresentation(
                isPresented: $isReactionsUsersSheetPresented,
                detents: [.medium()]
            ) {
                CustomReactionsUsersSheetView(isPresented: $isReactionsUsersSheetPresented, viewModel: viewModel)
            }
    }
    
    private func imageIcon(for reaction: MessageReactionType) -> UIImage? {
        images.availableReactions[reaction]?.smallIcon
    }
    
    private func stringIcon(for reaction: MessageReactionType) -> String? {
        switch reaction.id {
        case "heart":
            return "❤️"
        case "tears-of-joy":
            return "😂"
        case "thumbs-up":
            return "👍"
        case "astonished":
            return "😲"
        case "fire":
            return "🔥"
        default:
            return nil
        }
    }
    
    private var message: ChatMessage {
        viewModel.message
    }
    
    private var reactions: [MessageReactionType] {
         let reactionScores = viewModel.message.reactionScores

         return reactionScores.keys.filter { reactionType in
             (reactionScores[reactionType] ?? 0) > 0
         }
         .sorted(by: utils.sortReactions)
     }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
    
    private func count(for reaction: MessageReactionType) -> Int {
        message.reactionScores[reaction] ?? 0
    }
}
