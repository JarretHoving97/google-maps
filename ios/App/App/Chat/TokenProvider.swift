// swiftlint:disable all
import Foundation
import SwiftKeychainWrapper
import StreamChat

enum TokenProviderError: Error {
    case Unauthenticated
    case RequestAborted
    case ResponseInvalid
}

struct ParsedResponse: Decodable {
    var token: String?
}

/// Fetches a new Stream authentication token, if user is authenticated.
func loadStreamToken(_ url: String, _ completion: @escaping (Result<Token, Error>) -> Void) -> Void {
    guard let jwt = getValueFromKeychain(key: "jwt") else {
        completion(.failure(TokenProviderError.Unauthenticated))
        return
    }
    
    guard let url = URL(string: "\(url)/auth/stream/token") else {
        completion(.failure(TokenProviderError.RequestAborted))
        return
    }

    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)

    request.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(TokenProviderError.ResponseInvalid))
            print(error)
            return
        }

        guard let data = data, let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            completion(.failure(TokenProviderError.ResponseInvalid))
            print(response.debugDescription)
            return
        }

        do {
            let json = try JSONDecoder().decode(ParsedResponse.self, from: data)

            guard let tokenString = json.token else {
                completion(.failure(TokenProviderError.Unauthenticated))
                return
            }

            let token = try Token(rawValue: tokenString)

            completion(.success(token))
        } catch {
            completion(.failure(TokenProviderError.ResponseInvalid))
        }
    }

    task.resume()
}
