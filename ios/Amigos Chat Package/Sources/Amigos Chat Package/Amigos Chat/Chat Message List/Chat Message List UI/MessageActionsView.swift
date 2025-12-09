//
//  MessageActionsView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 19/11/2025.
//

import SwiftUI

public struct MessageActionsView: View {

    @StateObject var viewModel: MessageActionsViewModel

    private let messageActionCallBack: MessageActionCompletion

    public init(viewModel: MessageActionsViewModel, onAction callback: @escaping MessageActionCompletion = { _ in }) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.messageActionCallBack = callback
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.messageActions.indices, id: \.self) { index in
                let actionInfo = viewModel.messageActions[index]
                Button {
                    if actionInfo.confirmationPopup != nil {
                        viewModel.alertAction = actionInfo
                    } else {
                        actionInfo.action()
                    }
                } label: {
                    alertActionView(for: actionInfo)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageActionsView")
        .task { viewModel.loadMessageActions(onAction: messageActionCallBack) }
    }

    @ViewBuilder
    private func alertActionView(for action: CustomMessageAction) -> some View {
        HStack(spacing: 0) {
            Text(action.title)
                .font(.body)
                .foregroundColor(
                    action.isDestructive ? Color("Red") : Color(.darkText)
                )

            Spacer()

            Image(systemName: action.iconName)
                .customizable()
                .frame(maxWidth: 16, maxHeight: 16)
                .foregroundColor(
                    action.isDestructive ? Color("Red") : Color(.lightGray)
                )
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: 40)
    }
}

#Preview {
    struct PreviewMessageActionBuilder: MessageActionService {
        func createMessageActions(
            on actionCallback: @escaping MessageActionCompletion
        ) -> [CustomMessageAction] {
            [
                CustomMessageAction(
                    id: "Test1",
                    title: "Reply",
                    iconName: "",
                    action: {
                    },
                    confirmationPopup: nil,
                    isDestructive: false
                ),
                CustomMessageAction(
                    id: "Test2",
                    title: "Reply in Thread",
                    iconName: "",
                    action: {
                    },
                    confirmationPopup: nil,
                    isDestructive: false
                ),
                CustomMessageAction(
                    id: "Test3",
                    title: "Send",
                    iconName: "",
                    action: {},
                    confirmationPopup: nil,
                    isDestructive: false
                )
            ]
        }
    }
   return MessageActionsView(viewModel: MessageActionsViewModel(messageActionsBuilder: (PreviewMessageActionBuilder())))
}
