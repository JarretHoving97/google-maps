//
//  ChatRouterKey.swift
//  Amigos Chat Package
//
//  Created by Jarret on 19/12/2025.
//

import Foundation
import StreamChatSwiftUI

private struct ChatRouterKey: InjectionKey {
    static var currentValue: Router?
}

extension InjectedValues {
    var chatRouter: Router? {
        get { Self[ChatRouterKey.self] }
        set { Self[ChatRouterKey.self] = newValue}
    }
}
