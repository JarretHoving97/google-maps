//
//  SuperStatusKey.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/01/2026.
//

import StreamChatSwiftUI

private struct SuperStatusKey: InjectionKey {
    static var currentValue = SuperStatusController()
}

public extension InjectedValues {
    var superStatus: SuperStatusController {
        get { Self[SuperStatusKey.self] }
        set { Self[SuperStatusKey.self] = newValue }
    }
}
