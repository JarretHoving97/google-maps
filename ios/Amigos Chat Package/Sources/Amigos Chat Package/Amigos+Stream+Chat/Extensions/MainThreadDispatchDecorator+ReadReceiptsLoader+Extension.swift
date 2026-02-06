//
//  MainThreadDispatchDecorator+ReadReceiptsLoader+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 20/01/2026.
//

import Foundation

extension MainTheadDispatchDecorator: ReadReceiptsLoader where T == ReadReceiptsLoader {

    func load(completion: @escaping ReadReceiptsResult) {
        return decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
