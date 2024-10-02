import StreamChat
import SwiftUI
import StreamChatSwiftUI

class CustomMoreChannelActionsViewModel: MoreChannelActionsViewModel {
    
    @Injected(\.chatClient) private var chatClient
    
    /// Published vars.
    @Published var channelActions: [ChannelAction] = []
    @Published var alertShown = false
    @Published public var showMoreChannelActionsView = false
    @Published var members = [ChatChannelMember]()
    @Published var alertAction: ChannelAction? {
        didSet {
            alertShown = alertAction != nil
        }
    }
    
    public var channelController: ChatChannelController?
    
    public override init(
        channel: ChatChannel,
        channelActions: [ChannelAction]
    ) {
        super.init(channel: channel, channelActions: channelActions)
        self.channelController = chatClient.channelController(for: channel.cid)
        self.channelActions = channelActions
        members = channel.lastActiveMembers.filter { [unowned self] member in
            member.id != chatClient.currentUserId
        }
    }
}

/// Default view for the channel more actions view.
public struct CustomMoreChannelActionsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts

    @ObservedObject var viewModel: CustomMoreChannelActionsViewModel
    @State private var isPresented = false

    @State private var presentedView: AnyView? {
        didSet {
            isPresented = presentedView != nil
        }
    }

    public var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(viewModel.channelActions.enumerated()), id: \.offset) { index, action in
                if index > 0 {
                    Divider()
                }
                
                HStack {
                    if let destination = action.navigationDestination {
                        Button {
                            presentedView = destination
                        } label: {
                            CustomActionItemView(
                                title: action.title,
                                iconName: action.iconName,
                                isDestructive: action.isDestructive
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                    } else {
                        Button {
                            if action.confirmationPopup != nil {
                                viewModel.alertAction = action
                            } else {
                                action.action()
                            }
                        } label: {
                            CustomActionItemView(
                                title: action.title,
                                iconName: action.iconName,
                                isDestructive: action.isDestructive
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                    }
                }
            }
        }
        .accessibilityIdentifier("MoreChannelActionsView")
    }
}

/// Default view for the channel more actions view.
public struct CustomMoreChannelActionsContainerView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts

    var factory: Factory
    @ObservedObject var viewModel: CustomMoreChannelActionsViewModel
    @State private var isPresented = false
    var onDismiss: () -> Void

    @State private var presentedView: AnyView? {
        didSet {
            isPresented = presentedView != nil
        }
    }

    public init(
        factory: Factory,
        channel: ChatChannel,
        channelActions: [ChannelAction],
        onDismiss: @escaping () -> Void
    ) {
        self.factory = factory
        _viewModel = ObservedObject(
            wrappedValue: CustomMoreChannelActionsViewModel(
                channel: channel,
                channelActions: channelActions
            )
        )
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack {
            Spacer()
            
            CustomMoreChannelActionsView(viewModel: viewModel)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(colors.background1))
                .cornerRadius(12)
                .padding(.all, 12)
                .padding(.bottom, bottomSafeArea)
                .foregroundColor(Color(colors.text))
                .opacity(viewModel.alertShown ? 0 : 1)
                .onAppear {
                    // Stream doesn't understand that the actions need to be reactive somehow, so we set them on appear.
                    if let channel = viewModel.channelController?.channel {
                        viewModel.channelActions = factory.supportedMoreChannelActions(for: channel, onDismiss: onDismiss, onError: {_ in })
                    }
                }
        }
        .alert(isPresented: $viewModel.alertShown) {
            let title = viewModel.alertAction?.confirmationPopup?.title ?? ""
            let message = viewModel.alertAction?.confirmationPopup?.message ?? ""
            let buttonTitle = viewModel.alertAction?.confirmationPopup?.buttonTitle ?? ""

            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .destructive(Text(buttonTitle)) {
                    viewModel.alertAction?.action()
                },
                secondaryButton: .cancel()
            )
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            onDismiss()
        }
        .fullScreenCover(isPresented: $isPresented) {
            if let fullScreenView = presentedView {
                CustomMoreChannelActionsFullScreenWrappingView(presentedView: fullScreenView) {
                    presentedView = nil
                }
            }
        }
        .accessibilityIdentifier("MoreChannelActionsView")
    }
}

/// Default wrapping view for the channel more actions full screen presented view.
struct CustomMoreChannelActionsFullScreenWrappingView: View {
    @Injected(\.images) private var images

    let presentedView: AnyView
    let onDismiss: () -> Void

    public var body: some View {
        NavigationView {
            presentedView
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            onDismiss()
                        } label: {
                            Image(uiImage: images.close)
                                .customizable()
                                .frame(height: 16)
                        }
                    }
                }
        }
    }
}
