//
//  CustomAppCheckProviderFactory+TokenProvider+Chat+Extension.swift
//  App
//
//  Created by Jarret on 25/03/2026.
//

import Foundation
import Amigos_Chat_Package

extension FirebaseAppCheck: AppTokenProvider {

    public func getToken(completion: @escaping (Result<String, any Error>) -> Void) {
        getToken(forceRefresh: false, completion: completion)
    }
}
