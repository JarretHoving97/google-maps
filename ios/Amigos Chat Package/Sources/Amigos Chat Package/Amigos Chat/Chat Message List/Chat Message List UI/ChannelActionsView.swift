//
//  ChannelActionsView.swift
//  Amigos Chat Package
//
//  Created by Jarret on 07/11/2025.
//

import SwiftUI

struct ChannelActionsView: View {

    @ObservedObject var viewModel: CustomChannelActionViewModel

    let callbackActions: CallBackActions

    @State private var didAppear = false

    @State private var confirmationAction: CustomChannelAction?

    init(
        viewModel: CustomChannelActionViewModel,
        callbackActions: CallBackActions = CallBackActions()
    ) {
        self.viewModel = viewModel
        self.callbackActions = callbackActions
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                ForEach(viewModel.actions) { action in
                    let image = viewModel.imageIcon(for: action)

                    Button {
                        performAction(for: action)
                    } label: {
                        HStack {
                            Text(action.title)
                                .font(.subheadline)
                            Spacer()

                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12, alignment: .center)
                                .font(.headline)
                        }
                        .padding(16)
                    }
                    .frame(maxWidth: .infinity)
                    .tint(action.isDestructive ? Color(.red) : Color("Grey Dark"))
                    .background(Color(.pale))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 40, leading: 16, bottom: 36, trailing: 16))
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .offset(y: didAppear ? 0 : heightForActions)
            .onAppear {
                withAnimation(
                    .spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.2)
                ) {
                    didAppear = true
                }
            }
        }
        .ignoresSafeArea(.all)
        .background(.black.opacity(0.3))
        .onTapGesture { performAction(for: callbackActions.onClose) }
        .alert(
            isPresented: Binding(
                get: { confirmationAction != nil },
                set: { newValue in
                    if !newValue {
                        confirmationAction = nil
                    }
                }
            ),
            content: {
                let info = confirmationAction?.confirmationInfo ?? CustomConfirmationInfo()
                let action = confirmationAction?.action ?? {}
                return Alert(
                    title: Text(info.title),
                    message: Text(info.message),
                    primaryButton: .destructive(
                        Text(info.buttonTitle),
                        action: { performAction(for: action) }
                    ),
                    secondaryButton: .cancel()
                )
            }
        )
    }

    private func performAction(for action: CustomChannelAction) {

        // perform action in confirmation pop-up
        if action.confirmationInfo != nil {
            confirmationAction = action
            return
        }

        performAction(for: action.action)
    }

    private func performAction(for closure: @escaping () -> Void) {

        withAnimation(.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.2)) {
            didAppear = false
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.3,
            execute: { closure() }
        )
    }

    private var heightForActions: CGFloat {
        return CGFloat(viewModel.actions.count * 140)
    }
}

extension ChannelActionsView {

    struct CallBackActions {
        let onDissmiss: () -> Void
        let onError: (Error) -> Void
        let onClose: () -> Void

        init(onDissmiss: @escaping () -> Void, onError: @escaping (Error) -> Void, onClose: @escaping () -> Void) {
            self.onDissmiss = onDissmiss
            self.onError = onError
            self.onClose = onClose
        }

        init() {
            onDissmiss = {}
            onError = {_ in }
            onClose = {}
        }
    }
}

#Preview {
    ChannelActionsView(
        viewModel: CustomChannelActionViewModel(
            actions: [
                CustomChannelAction(
                    title: "Community Bekijken",
                    action: {}
                ),
                CustomChannelAction(
                    title: "Community Bekijken",
                    action: {}
                ),
                CustomChannelAction(
                    title: "Community Bekijken",
                    action: {}
                )
            ]
        )
    )
}
