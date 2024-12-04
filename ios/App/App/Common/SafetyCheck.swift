import Foundation

enum RequestError: Error {
    case invalidUrl
    case requestAborted
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

func updateSafetyCheck(
    userId: String,
    state: SafetyCheckState,
    reason: SafetyCheckReason?,
    completion: @escaping (Result<Void, Error>
) -> Void) {
    guard let jwt = getValueFromKeychain(key: "jwt") else {
        completion(.failure(TokenProviderError.Unauthenticated))
        return
    }

    guard let url = URL(string: "\(BuildConfiguration.AmigosApiUrl)/graphql") else {
        completion(.failure(RequestError.invalidUrl))
        return
    }

    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)

    request.httpMethod = "POST"

    let body = getRequestBody(userId: userId, state: state, reason: reason)

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

        print(data, response)

        guard let data, let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            completion(.failure(RequestError.responseInvalid))
            return
        }

        completion(.success(()))
    }

    task.resume()
}
