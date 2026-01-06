//
//  ChatNavigationViewModel.swift
//  Amigos Chat Package
//
//  Created by Jarret on 19/12/2025.
//

import SwiftUI
import StreamChat

@MainActor
public class ChatNavigationViewModel: ObservableObject, RoutingProtocol {

    public typealias Route = ChatRoute

    @Published public var path = [ChatRoute]()

    private let client: ChatClient

    let clientNavigationNotifier: ClientNavigationNotifier

    public init(
        client: ChatClient,
        clientNavigationReceiver: ClientNavigationNotifier,
    ) {
        self.client = client
        self.clientNavigationNotifier = clientNavigationReceiver
    }

    func handlePathChange(from old: [ChatRoute], to new: [ChatRoute]) {

        // if path is nil, we don't want to notify the client
        if new.count < old.count, let last = old.last, last.path != nil {
            clientNavigationNotifier.notifyNavigateBackToListeners(dismiss: false)
        }

        if new.count > old.count, let last = new.last {
            clientNavigationNotifier.notifyNavigateToListeners(route: last.path, dismiss: false)
        }
    }

    public func push(_ route: ChatRoute) {

        if case .client = route {
            // navigate in client
            clientNavigationNotifier.notifyNavigateToListeners(route: route.path, dismiss: true)
            return
        }

        path.append(route)
    }

    func close() {
        clientNavigationNotifier.notifyNavigateBackToListeners(dismiss: true)
    }
}
