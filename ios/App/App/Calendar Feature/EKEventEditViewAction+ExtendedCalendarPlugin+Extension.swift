//
//  EKEventEditViewAction+ExtendedCalendarPlugin+Extension.swift
//  App
//
//  Created by Jarret on 28/01/2026.
//

import EventKitUI

extension EKEventEditViewAction {

    func toCalendarPluginAction() -> ExtendedCalendarPlugin.CallbackAction {
        switch self {
        case .deleted:
            return .deleted
        case .saved:
            return .saved
        default:
            return .canceled
        }
    }
}
