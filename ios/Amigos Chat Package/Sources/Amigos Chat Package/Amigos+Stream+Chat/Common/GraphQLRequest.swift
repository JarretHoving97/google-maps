import Foundation

enum RequestError: Error {
    case invalidUrl
    case requestAborted
    case requestInvalid
}

func getRequestBody(userId: String, state: SafetyCheckState, reason: SafetyCheckReason?) -> String {
    if state == .positive {
        return """
            {
              "operationName": "AddUserPositiveReview",
              "variables": {
                "input": {
                  "userId": "\(userId)"
                }
              },
              "query": "mutation AddUserPositiveReview($input: AddUserPositiveReviewInput!) {addUserPositiveReview(input: $input){__typename success}}"
            }
        """
    } else {
        return """
            {
              "operationName": "AddUserNegativeReview",
              "variables": {
                "input": {
                  "userId": "\(userId)",
                  "reason": "\(reason!.rawValue)",
                  "message": null
                }
              },
              "query": "mutation AddUserNegativeReview($input: AddUserNegativeReviewInput!) {addUserNegativeReview(input: $input) {__typename success }}"
            }
        """
    }
}

enum TokenProviderError: Error {
    case unauthenticated
}

func executeGraphQLRequest(
    body: String,
    completion: @escaping (Result<Data, Error>
) -> Void) {
    guard let jwt = KeychainController.jwtLoader?.getValueFromKeychain(key: "jwt") else {
        completion(.failure(TokenProviderError.unauthenticated))
        return
    }

    guard var url = CurrentEnvironment.apiUrl else {
        completion(.failure(RequestError.invalidUrl))
        return
    }

    url.appendPathComponent("graphql")

    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)

    request.httpMethod = "POST"
    request.httpBody = body.data(using: .utf8)

    let headers = [
        "Authorization": "Bearer \(jwt)",
        "Content-Type": "application/json"
    ]

    for (name, value) in headers {
        request.addValue(value, forHTTPHeaderField: name)
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(RequestError.requestInvalid))
            print(error)
            return

        }
        guard let data, let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            completion(.failure(RequestError.requestInvalid))
            return
        }

        completion(.success(data))
    }

    task.resume()
}
