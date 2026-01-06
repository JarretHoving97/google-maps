//
//  RouteInfo.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

import Foundation

public struct RouteInfo: Equatable, Hashable {

    public let route: ClientRoute?
    public let dismiss: Bool

    public init(route: ClientRoute, dismiss: Bool = false) {
        self.route = route
        self.dismiss = dismiss
    }

    public init(dismiss: Bool) {
        self.route = nil
        self.dismiss = true
    }
}

extension RouteInfo {

    static var dismiss: RouteInfo {
        RouteInfo(dismiss: true)
    }
}
