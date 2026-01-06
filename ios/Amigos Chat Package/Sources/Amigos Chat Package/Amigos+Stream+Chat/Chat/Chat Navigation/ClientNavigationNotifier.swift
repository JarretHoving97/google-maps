//
//  ClientNavigationNotifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/12/2025.
//

import Foundation

public protocol ClientNavigationNotifier {
    func notifyNavigateToListeners(route: String?, dismiss: Bool)
    func notifyNavigateBackToListeners(dismiss: Bool)
}
