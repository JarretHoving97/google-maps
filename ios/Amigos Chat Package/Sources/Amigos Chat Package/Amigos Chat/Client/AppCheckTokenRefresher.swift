//
//  AppCheckTokenRefresher.swift
//  Amigos Chat Package
//
//  Created by Jarret on 24/03/2026.
//

import Foundation

public protocol AppTokenProvider {
    func getToken(completion: @escaping (Result<String, Error>) -> Void)
}
