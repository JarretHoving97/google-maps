//
//  ChannelCreationService.swift
//  Amigos Chat Package
//
//  Created by Jarret on 14/01/2025.
//

import Foundation
import StreamChatSwiftUI

public protocol ChannelCreationService {
    typealias FindOrCreateChannelResult = (Result<String, Error>) -> Void
    func load(for user: String, completion: @escaping FindOrCreateChannelResult)
    func load(for user: String) async throws -> String
}

public class RemoteFindOrCreateChannelService: ChannelCreationService {

    @Injected(\.tokenProvider) private var tokenProvider

    public init() {}

    public func load(for user: String, completion: @escaping FindOrCreateChannelResult) {
        findOrCreateChat(receiverId: user, completion: completion)
    }

    public func load(for user: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.findOrCreateChat(receiverId: user) { result in
                switch result {
                case .success(let channelId):
                    continuation.resume(returning: channelId)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func findOrCreateChat(
        receiverId: String,
        completion: @escaping FindOrCreateChannelResult
    ) {
        let body = getRequestBodyForFindOrCreateChat(receiverId: receiverId)

        executeGraphQLRequest(body: body, tokenProvider: tokenProvider) { result in
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
