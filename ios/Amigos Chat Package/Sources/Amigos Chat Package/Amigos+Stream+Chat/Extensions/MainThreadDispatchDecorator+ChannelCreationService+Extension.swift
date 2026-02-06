//
//  MainThreadDispatchDecorator+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/01/2026.
//

import Foundation

/// Decorate ChannelCreationService to dispatch on main thread.
extension MainTheadDispatchDecorator: ChannelCreationService where T == ChannelCreationService {

    @MainActor
    public func load(for user: String) async throws -> String {
        return try await decoratee.load(for: user)
    }

    public func load(for user: String, completion: @escaping FindOrCreateChannelResult) {
        return decoratee.load(for: user, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}
