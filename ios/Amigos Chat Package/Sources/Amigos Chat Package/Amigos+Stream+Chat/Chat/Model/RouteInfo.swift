//
//  RouteInfo.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

import Foundation

public struct RouteInfo {

    public let route: ChannelRoute?
    public let dismiss: Bool

    public init(route: ChannelRoute, dismiss: Bool = false) {
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
