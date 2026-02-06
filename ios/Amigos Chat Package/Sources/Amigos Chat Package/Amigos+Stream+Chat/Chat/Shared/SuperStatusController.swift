//
//  TrialInfoController.swift
//  Amigos Chat Package
//
//  Created by Jarret on 13/01/2025.
//

import Foundation

public enum SuperEntitlementStatus: String {
    case unavailable = "Unavailable"
    case available = "Available"
    case active = "Active"
}

public class SuperStatusController {
    public var chatTrialUntil: Date?
    public var superEntitlementStatus: SuperEntitlementStatus?
}
