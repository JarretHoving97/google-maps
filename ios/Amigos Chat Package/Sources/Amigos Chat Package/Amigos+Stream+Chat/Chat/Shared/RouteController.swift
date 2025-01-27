//
//  RouteController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

class RouteController {

    public private(set) static var routeAction: ((RouteInfo) -> Void)?

    public static func setupRouteAction(action: @escaping ((RouteInfo) -> Void)) {
        self.routeAction = action
    }
}
