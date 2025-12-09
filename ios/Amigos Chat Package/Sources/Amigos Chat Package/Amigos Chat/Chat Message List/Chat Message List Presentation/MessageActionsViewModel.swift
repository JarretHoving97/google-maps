//
//  MessageActionsViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/11/2025.
//

import SwiftUI

public class MessageActionsViewModel: ObservableObject {

    @Published var messageActions = [CustomMessageAction]()

    @Published var alertAction: CustomMessageAction?

    private var messageActionsBuilder: MessageActionService

    init(messageActionsBuilder: MessageActionService) {
        self.messageActionsBuilder = messageActionsBuilder
    }

    func loadMessageActions(onAction callback: @escaping MessageActionCompletion) {
        messageActions = messageActionsBuilder.createMessageActions(on: callback)
    }
}
