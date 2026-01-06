//
//  AnyRouter.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/12/2025.
//

import SwiftUI

public typealias Router = AnyRouter<ChatRoute>

@MainActor
public final class AnyRouter<Route: Hashable>: ObservableObject {
    private let _push: (Route) -> Void

    public init<R: RoutingProtocol>(_ base: R) where R.Route == Route {
        _push = base.push
    }

    func push(_ route: Route) { _push(route) }
}
