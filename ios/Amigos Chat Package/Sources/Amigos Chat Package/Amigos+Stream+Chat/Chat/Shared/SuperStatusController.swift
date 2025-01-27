//
//  TrialInfoController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

import Foundation

public class SuperStatusController {

    public enum SuperEntitlementStatus {
        case unavailable
        case available
        case active
    }

    public var chatTrialUntil: Date?
    public var superEntitlementStatus: SuperEntitlementStatus?

    public static let shared = SuperStatusController()

    private init() {}
}
