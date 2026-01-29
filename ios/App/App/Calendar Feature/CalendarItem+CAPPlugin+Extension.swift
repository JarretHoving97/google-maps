//
//  CalendarItem+CAPPlugin+Extension.swift
//  App
//
//  Created by Jarret on 09/01/2026.
//

import Foundation
import Capacitor

extension CalendarItem {

    init(pluginCall: CAPPluginCall) throws {
        self.title = try pluginCall.requireString("title")
        self.startDate = try pluginCall.requireISO8601Date("startDate")
        self.endDate = pluginCall.getISO8601Date("endDate")
        self.location = pluginCall.getString("location")
        self.notes = pluginCall.getString("notes")
    }
}
