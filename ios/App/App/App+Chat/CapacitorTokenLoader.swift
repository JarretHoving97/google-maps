//
//  CapacitorTokenLoader.swift
//  App
//
//  Created by Jarret on 10/01/2025.
//

import Foundation
import Amigos_Chat_Package
import SwiftKeychainWrapper

class CapacitorTokenLoader: TokenProvider {

    var keychainLoader: KeychainLoader?

    struct ParsedResponse: Decodable {
        var token: String?
    }

    public enum Error: Swift.Error {
        case unauthenticated
        case requestAborted
        case responseInvalid
    }

    let url: String

    init(url: String, keychainLoader: KeychainLoader) {
        self.url = url
        self.keychainLoader = keychainLoader
    }

    func loadToken(completion: @escaping TokenLoadResult) {
        guard let jwt = keychainLoader?.getValueFromKeychain(key: "jwt") else {
            completion(.failure(Error.unauthenticated))
            return
        }

        guard let url = URL(string: "\(url)/auth/stream/token") else {
            completion(.failure(Error.requestAborted))
            return
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)

        request.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(Error.responseInvalid))
                print(error)
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                completion(.failure(Error.responseInvalid))
                print(response.debugDescription)
                return
            }

            do {
                let json = try JSONDecoder().decode(ParsedResponse.self, from: data)

                guard let tokenString = json.token else {
                    completion(.failure(Error.unauthenticated))
                    return
                }
                let token = LocalToken(token: tokenString)

                completion(.success(token))
            } catch {
                completion(.failure(Error.responseInvalid))
            }
        }

        task.resume()
    }
}
