import SwiftUI
import StreamChatSwiftUI
import StreamChat

/// View for the message actions.
public struct CustomMessageActionsView: View {

    @Injected(\.colors) private var colors

    @StateObject var viewModel: MessageActionsViewModel

    var message: ChatMessage

    public init(for message: ChatMessage, messageActions: [MessageAction]) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory
                .makeMessageActionsViewModel(messageActions: messageActions)
        )
        self.message = message
    }

    var actions: [MessageAction] {
        let exceptions: [String] = [MessageActionId.flag, MessageActionId.pin]

        return viewModel.messageActions.filter({
            !exceptions.contains($0.id)
        })
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(actions) { action in
                VStack(spacing: 0) {
                    if let destination = action.navigationDestination {
                        NavigationLink {
                            destination
                        } label: {
                            CustomActionItemView(
                                title: action.title,
                                iconName: action.iconName,
                                isDestructive: action.isDestructive
                            )
                            .frame(maxWidth: .infinity, maxHeight: 40)
                        }
                        .buttonStyle(.plain)
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
                            .frame(maxWidth: .infinity, maxHeight: 40)
                        }
                        .buttonStyle(.plain)
                    }

                    Divider()
                }
                .padding(.leading)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("messageAction-\(action.id)")
            }
        }
        .padding(.trailing, 12)
        .background(Color(colors.background8))
        .roundWithBorder(cornerRadius: 12)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageActionsView")
    }
}
