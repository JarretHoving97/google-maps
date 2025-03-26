//
//  ChannelActionsModel.swift
//  Amigos Chat
//
//  Created by Jarret on 09/01/2025.
//

import Foundation

public enum ChannelRoute: Equatable {

    case profileRoute(id: String)
    case profileInviteRoute(id: String)
    case activityRoute(id: String)
    case mixerRoute(id: String)
    case inviteToActivityRoute(id: String)
    case manageActivityParticipantsRoute(id: String)

    case superAmigoRoute
    case onboardingRoute
    case howToHost
    case howToJoin
    case faq

    // pass through
    case path(String)

    public var value: String {
        switch self {

        case .profileRoute(let id):
            "/profile/\(id)"

        case .profileInviteRoute(let id):
            "/profile/\(id)/invite"

        case .activityRoute(let id):
            "/activity/\(id)"

        case .mixerRoute(let id):
            "/mixer/\(id)"
            
        case .inviteToActivityRoute(let id):
            "/activity/\(id)/invite"

        case .manageActivityParticipantsRoute(let id):
            "/manage-activity/\(id)/participants"

        case .superAmigoRoute:
            "/super-amigo"

        case .onboardingRoute:
            "/walkthrough"

        case .howToHost:
            "/walkthrough/host"

        case .howToJoin:
            "/walkthrough/join"

        case .faq:
            "/faq"

        case let .path(path):
            path
        }
    }
}
