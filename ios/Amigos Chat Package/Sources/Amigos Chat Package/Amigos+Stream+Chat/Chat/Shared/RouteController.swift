//
//  RouteController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

public class RouteController {

    public private(set) static var routeAction: ((RouteInfo) -> Void)?

    public static func setupRouteAction(action: @escaping ((RouteInfo) -> Void)) {
        self.routeAction = action
    }
}

/// ChatViewController's backbutton action when there is no default UINavigationbar back button
extension RouteController {

    public private(set) static var headerDismissButtonAction: ((RouteInfo) -> Void)?

    public static func setHeaderBackButton(action: @escaping ((RouteInfo) -> Void)) {
        self.headerDismissButtonAction = action
    }
}
