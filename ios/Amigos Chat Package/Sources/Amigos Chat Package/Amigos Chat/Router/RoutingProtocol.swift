//
//  RoutingProtocol.swift
//  Amigos Chat Package
//
//  Created by Jarret on 19/12/2025.
//

import SwiftUI

@MainActor
public protocol RoutingProtocol: AnyObject {

    associatedtype Route: Hashable

    var path: [Route] { get set }

    func push(_ route: Route)
    func pop()
    func popToRoot()
    func setStack(_ routes: [Route])
}

public extension RoutingProtocol {

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func setStack(_ routes: [Route]) {
        path = routes
    }
}
