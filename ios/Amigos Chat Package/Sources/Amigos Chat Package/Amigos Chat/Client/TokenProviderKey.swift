//
//  TokenProvider.swift
//  Amigos Chat Package
//
//  Created by Jarret on 25/03/2026.
//

// to make use of `InjectionKey`
import StreamChatSwiftUI

private struct TokenProviderKey: InjectionKey {
    static var currentValue: AppTokenProvider?
}

extension InjectedValues {

   public var tokenProvider: AppTokenProvider? {
        get { Self[TokenProviderKey.self] }
        set { Self[TokenProviderKey.self] = newValue }
    }
}
