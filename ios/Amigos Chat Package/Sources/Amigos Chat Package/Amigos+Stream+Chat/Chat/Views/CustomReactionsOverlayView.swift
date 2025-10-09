import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomReactionsOverlayView<Factory: ViewFactory>: View {

    @StateObject var viewModel: ReactionsOverlayViewModel

    @State private var popIn = false
    @State private var willPopOut = false
    @Environment(\.colorScheme) private var colorScheme

    var factory: Factory
    var channel: ChatChannel

    var bottomOffset: CGFloat = 0
    var messageDisplayInfo: MessageDisplayInfo
    var onBackgroundTap: () -> Void
    var onActionExecuted: (MessageActionInfo) -> Void

    private struct UI {
        static var padding: CGFloat { 12 }
        static var reactionHeight: CGFloat { 56 }
        static var reactionSpacingToBubble: CGFloat { 8 }
        static var actionsSpacingToBubble: CGFloat { 12 }
        static var messageItemSize: CGFloat { 40 }
        static var minBottomClearance: CGFloat { 72 }
        static var topHeadroom: CGFloat { 16 }
        static var minMessageHeight: CGFloat { 80 }
        static var visualTopSpacingWhenScrollable: CGFloat { 12 }
        static var visualBottomSpacingWhenScrollable: CGFloat { 8 }
        static var avatarSpacingFromBubble: CGFloat { 8 }
        static var overlayFixedWidth: CGFloat { 240 }
    }

    private var messageActionsCount: Int

    public init(
        factory: Factory,
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        bottomOffset: CGFloat = 0,
        onBackgroundTap: @escaping () -> Void,
        onActionExecuted: @escaping (MessageActionInfo) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory.makeReactionsOverlayViewModel(
                message: messageDisplayInfo.message
            )
        )
        self.channel = channel
        self.factory = factory
        self.bottomOffset = bottomOffset
        self.messageDisplayInfo = messageDisplayInfo
        self.onBackgroundTap = onBackgroundTap
        self.onActionExecuted = onActionExecuted
        self.messageActionsCount = factory.supportedMessageActions(
            for: messageDisplayInfo.message,
            channel: channel,
            onFinish: { _ in },
            onError: { _ in }
        ).count
    }

    public var body: some View {
        GeometryReader { geo in
            let message = MessageMapper().map(messageDisplayInfo.message)
            let layout = Layout(
                geo: geo,
                messageDisplayInfo: messageDisplayInfo,
                bottomOffset: bottomOffset,
                actionsCount: messageActionsCount
            )

            ZStack(alignment: .topLeading) {
                VisualEffectBlur(blurStyle: .systemThinMaterialLight)
                    .ignoresSafeArea()
                    .onTapGesture { dismissReactionsOverlay { } }
                    .alert(isPresented: $viewModel.errorShown) { Alert.defaultErrorAlert }

                ScrollView(.vertical, showsIndicators: true) {
                    MessageView(
                        viewModel: MessageViewModel(message: message)
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .allowsHitTesting(false)
                }
                .frame(
                    width: layout.messageContainerSize.width,
                    height: layout.messageContainerSize.height,
                    alignment: .topLeading
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .offset(x: layout.messageLocalOffset.x, y: layout.messageLocalOffset.y)
                .scaleEffect(popIn ? 1.0 : 0.98, anchor: .center)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 8)
                .animation(popAnimation, value: popIn)

                if showAvatar(for: message) {
                    let author = messageDisplayInfo.message.author
                    let userInfo = UserDisplayInfo(
                        id: author.id,
                        name: author.name ?? author.id,
                        imageURL: author.imageURL,
                        role: author.userRole
                    )

                    MessageAvatarView(avatarURL: userInfo.imageURL)
                        .frame(width: layout.avatarSize.width, height: layout.avatarSize.height)
                        .offset(x: layout.avatarLocalOffset.x, y: layout.avatarLocalOffset.y)
                        .opacity(willPopOut ? 0 : 1)
                        .scaleEffect(popIn ? 1 : (willPopOut ? 0.9 : 0.95))
                        .animation(popAnimation, value: popIn)
                        .allowsHitTesting(false)
                }

                CustomReactionsOverlayContainer(
                    message: viewModel.message,
                    contentRect: layout.shiftedMessageContainerGlobal,
                    outerHorizontalPadding: 0,
                    outerVerticalPadding: 0,
                    onReactionTap: { reaction in
                        dismissReactionsOverlay { viewModel.reactionTapped(reaction) }
                    }
                )
                .frame(width: layout.overlayWidth)
                .offset(x: layout.overlayLocalX, y: layout.reactionLocalY)
                .opacity(willPopOut ? 0 : 1)
                .scaleEffect(popIn ? 1 : (willPopOut ? 0.9 : 0.95))
                .animation(popAnimation, value: popIn)
                .zIndex(2)

                factory.makeMessageActionsView(
                    for: messageDisplayInfo.message,
                    channel: channel,
                    onFinish: { actionInfo in onActionExecuted(actionInfo) },
                    onError: { _ in viewModel.errorShown = true }
                )
                .frame(width: layout.overlayWidth, height: layout.actionsHeight, alignment: .topLeading)
                .offset(x: layout.overlayLocalX, y: layout.actionsLocalY)
                .opacity(willPopOut ? 0 : 1)
                .scaleEffect(popIn ? 1 : (willPopOut ? 0.9 : 0.95))
                .animation(popAnimation, value: popIn)
                .zIndex(1)
            }
        }
        .onAppear { popIn = true }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsOverlayView")
    }

    private var popAnimation: Animation {
        .spring(response: 0.25, dampingFraction: 0.85, blendDuration: 0.15)
    }

    private func dismissReactionsOverlay(completion: @escaping () -> Void) {
        withAnimation(popAnimation) {
            willPopOut = true
            popIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onBackgroundTap()
            completion()
        }
    }

    private func showAvatar(for message: Message) -> Bool {
        !messageDisplayInfo.message.isSentByCurrentUser &&

        !channel.isDirectMessageChannel &&
        message.type != .system
    }

    private struct Layout {

        let geo: GeometryProxy
        let messageDisplayInfo: MessageDisplayInfo
        let bottomOffset: CGFloat
        let actionsCount: Int

        private var viewSafe: EdgeInsets { geo.safeAreaInsets }
        private var winSafe: UIEdgeInsets { windowSafeAreaInsets() }
        private var safeTop: CGFloat { max(winSafe.top, viewSafe.top) }
        private var safeBottom: CGFloat { max(winSafe.bottom, viewSafe.bottom) }

        private var screen: CGRect { geo.frame(in: .global) }
        private var bubble: CGRect { messageDisplayInfo.frame }

        var messageContainerSize: CGSize {
            CGSize(width: bubble.width, height: clampedMessageHeight)
        }

        var messageLocalOffset: CGPoint {
            CGPoint(x: bubble.minX - screen.minX, y: (bubble.minY - screen.minY) + groupOffsetY)
        }

        var overlayWidth: CGFloat {
            let available = screen.width - viewSafe.leading - viewSafe.trailing - 2 * UI.padding
            return min(UI.overlayFixedWidth, available)
        }

        var overlayLocalX: CGFloat {
            let xAlignment: CGFloat
            if messageDisplayInfo.message.isRightAligned {
                xAlignment = clampedTrailingX(
                    alignToTrailingOf: bubble,
                    containerWidth: overlayWidth,
                    screen: screen,
                    safe: viewSafe
                )
            } else {
                xAlignment = clampedLeadingX(
                    alignToLeadingOf: bubble,
                    containerWidth: overlayWidth,
                    screen: screen,
                    safe: viewSafe
                )
            }
            return xAlignment - screen.minX
        }

        var reactionLocalY: CGFloat {
            (idealReactionY - screen.minY) + groupOffsetY
        }

        var actionsLocalY: CGFloat {
            (idealActionsY - screen.minY) + groupOffsetY
        }

        var actionsHeight: CGFloat {
            min(screen.height / 3, CGFloat(actionsCount) * UI.messageItemSize)
        }

        var avatarSize: CGSize { .messageAvatarSize }

        var avatarLocalOffset: CGPoint {
            let xAlignment = (bubble.minX - screen.minX) - UI.avatarSpacingFromBubble - avatarSize.width
            let yAlignment = (messageContainerGlobal.minY - screen.minY) + (messageContainerGlobal.height - avatarSize.height) + groupOffsetY
            return CGPoint(x: xAlignment, y: yAlignment)
        }

        var shiftedMessageContainerGlobal: CGRect {
            messageContainerGlobal.offsetBy(dx: 0, dy: groupOffsetY)
        }

        private var topReserved: CGFloat { safeTop + UI.padding }

        private var bottomReserved: CGFloat { safeBottom + max(bottomOffset, UI.minBottomClearance) + UI.padding }

        private var bandHeight: CGFloat { max(0, screen.height - topReserved - bottomReserved) }

        private var rawMaxMessageHeight: CGFloat {
            max(0, bandHeight - (UI.reactionHeight + UI.reactionSpacingToBubble) - (actionsHeight + UI.actionsSpacingToBubble))
        }

        private var visualTopSpacing: CGFloat {
            bubble.height > rawMaxMessageHeight + 0.5 ? UI.visualTopSpacingWhenScrollable : 0
        }

        private var visualBottomSpacing: CGFloat {
            bubble.height > rawMaxMessageHeight + 0.5 ? UI.visualBottomSpacingWhenScrollable : 0
        }

        private var maxMessageContainerHeight: CGFloat {
            max(UI.minMessageHeight, rawMaxMessageHeight - visualTopSpacing - visualBottomSpacing)
        }

        private var clampedMessageHeight: CGFloat {
            min(bubble.height, maxMessageContainerHeight)
        }

        private var messageContainerGlobal: CGRect {
            CGRect(x: bubble.minX, y: bubble.minY, width: bubble.width, height: clampedMessageHeight)
        }

        private var topBound: CGFloat { screen.minY + topReserved }
        private var bottomBound: CGFloat { screen.maxY - bottomReserved }

        private var desiredTopY: CGFloat { messageContainerGlobal.minY }

        private var lowerAllowedY: CGFloat {
            topBound + (UI.reactionHeight + UI.reactionSpacingToBubble) + visualTopSpacing + UI.topHeadroom
        }

        private var upperAllowedY: CGFloat {
            max(
                lowerAllowedY,
                bottomBound - (clampedMessageHeight + actionsHeight + UI.actionsSpacingToBubble) - visualBottomSpacing
            )
        }

        private var clampedTopY: CGFloat {
            min(max(desiredTopY, lowerAllowedY), upperAllowedY)
        }

        private var groupOffsetY: CGFloat { clampedTopY - desiredTopY }

        private var idealReactionY: CGFloat {
            messageContainerGlobal.minY - UI.reactionHeight - UI.reactionSpacingToBubble
        }

        private var idealActionsY: CGFloat {
            messageContainerGlobal.maxY + UI.actionsSpacingToBubble
        }

        private func clampedLeadingX(
            alignToLeadingOf bubble: CGRect,
            containerWidth: CGFloat,
            screen: CGRect,
            safe: EdgeInsets
        ) -> CGFloat {
            let minX = screen.minX + safe.leading + UI.padding
            let maxX = screen.maxX - safe.trailing - UI.padding
            let ideal = bubble.minX
            return min(max(ideal, minX), maxX - containerWidth)
        }

        private func clampedTrailingX(
            alignToTrailingOf bubble: CGRect,
            containerWidth: CGFloat,
            screen: CGRect,
            safe: EdgeInsets
        ) -> CGFloat {
            let minX = screen.minX + safe.leading + UI.padding
            let maxX = screen.maxX - safe.trailing - UI.padding
            let ideal = bubble.maxX - containerWidth
            return min(max(ideal, minX), maxX - containerWidth)
        }

        private func windowSafeAreaInsets() -> UIEdgeInsets {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
            else { return .zero }
            return keyWindow.safeAreaInsets
        }
    }
}
