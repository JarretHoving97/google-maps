//
//  MainTheadDispatchDecorator.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/01/2026.
//

import Foundation

/// Decorator to dispatch completion on main thread.
public final class MainTheadDispatchDecorator<T> {
    public let decoratee: T

    public init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }

        completion()
    }
}
