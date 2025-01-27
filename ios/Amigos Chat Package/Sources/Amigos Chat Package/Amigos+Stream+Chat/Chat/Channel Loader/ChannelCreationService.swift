//
//  ChannelCreationService.swift
//  Amigos Chat Package
//
//  Created by Jarret on 14/01/2025.
//

import Foundation

public protocol ChannelCreationService {
    typealias FindOrCreateChannelResult = (Result<String, Error>) -> Void
    func load(for user: String, completion: @escaping FindOrCreateChannelResult)
}


public class RemoteFindOrCreateChannelService: ChannelCreationService {

    public init() {}

    public func load(for user: String, completion: @escaping FindOrCreateChannelResult) {
        findOrCreateChat(receiverId: user, completion: completion)
    }

    private func findOrCreateChat(
        receiverId: String,
        completion: @escaping FindOrCreateChannelResult
    ) {
        let body = getRequestBodyForFindOrCreateChat(receiverId: receiverId)

        executeGraphQLRequest(body: body) { result in
            switch result {
            case .success(let data):
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("Failed to parse JSON.")
                    return
                }

                guard let dataField = json["data"] as? [String: Any] else {
                    print("Missing 'data' field in response.")
                    return
                }

                guard let payload = dataField["findOrCreateChat"] as? [String: Any] else {
                    print("Missing 'findOrCreateChat' payload in response.")
                    return
                }

                guard let channelId = payload["channelId"] as? String else {
                    print("Missing 'channelId' in payload.")
                    return
                }

                completion(.success(channelId))
            case .failure(let error):
                print("Something went wrong with the `findOrCreateChat` mutation:", error)
                completion(.failure(error))
            }
        }
    }

    private func getRequestBodyForFindOrCreateChat(receiverId: String) -> String {
        return """
        {
          "operationName": "FindOrCreateChat",
          "variables": {
            "input": {
              "receiverId": "\(receiverId)"
            }
          },
          "query": "mutation FindOrCreateChat($input: FindOrCreateChatInput!) { findOrCreateChat(input: $input) { __typename channelId } }"
        }
        """
    }
}
