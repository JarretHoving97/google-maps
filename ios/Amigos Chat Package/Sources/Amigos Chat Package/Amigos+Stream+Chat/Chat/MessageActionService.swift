//
//  MessageActionService.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/11/2025.
//

import Foundation

public typealias MessageActionCompletion = ((Result<CustomMessageActionInfo, Error>) -> Void)

public protocol MessageActionService {
    func createMessageActions(on actionCallback: @escaping MessageActionCompletion) -> [CustomMessageAction]
}
