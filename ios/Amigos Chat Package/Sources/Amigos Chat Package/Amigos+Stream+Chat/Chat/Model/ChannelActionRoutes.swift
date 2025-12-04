//
//  ChannelActionsModel.swift
//  Amigos Chat
//
//  Created by Jarret on 09/01/2025.
//

import Foundation

public enum ChannelRoute: Equatable {

    // direct message
    case profileRoute(id: String)
    case profileInviteRoute(id: String)

    // activity
    case activityRoute(id: String)
    case inviteToActivityRoute(id: String)
    case manageActivityParticipantsRoute(id: String)

    // community
    case communityRoute(id: String)
    case communityActivityInviteRoute(id: String)
    case manageCommunityParticipantsRoute(id: String)

    // other
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

        case .communityRoute(let id):
            "/community/\(id)"

        case .communityActivityInviteRoute(id: let id):
            "/community/\(id)/invite"

        case .manageCommunityParticipantsRoute(id: let id):
            "/manage-community/\(id)/participants"

        case .manageActivityParticipantsRoute(id: let id):
            "/manage-activity/\(id)/participants"

        case .inviteToActivityRoute(let id):
            "/activity/\(id)/invite"

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
