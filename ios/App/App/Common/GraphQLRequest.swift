import Foundation

enum RequestError: Error {
    case invalidUrl
    case grapquestAborted
    case responseInvalid
}

func getRequestBody(userId: String, state: SafetyCheckState, reason: SafetyCheckReason?) -> String {
    if state == .Positive {
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

func executeGraphQLRequest(body: String, completion: @escaping (Result<Data, Error>) -> Void) {
    guard let jwt = getValueFromKeychain(key: "jwt") else {
        completion(.failure(TokenProviderError.Unauthenticated))
        return
    }

    guard let url = URL(string: "\(BuildConfiguration.safetyCheckUrl)/graphql") else {
        completion(.failure(RequestError.invalidUrl))
        return
    }

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
            completion(.failure(RequestError.responseInvalid))
            print(error)
            return
        }

        guard let data, let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            completion(.failure(RequestError.responseInvalid))
            return
        }

        completion(.success((data)))
    }

    task.resume()
}
