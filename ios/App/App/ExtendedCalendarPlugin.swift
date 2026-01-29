//
//  ExtendedCalendarPlugin.swift
//  App
//
//  Created by Jarret on 09/01/2026.
//

import Foundation
import Capacitor

protocol ShowCalendarDelegate: AnyObject {
    func present(_ viewModel: CalendarViewModel)
}

@objc(ExtendedCalendarPlugin)
public class ExtendedCalendarPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "ExtendedCalendar"

    public var jsName = "ExtendedCalendar"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "createEventWithPrompt", returnType: CAPPluginReturnPromise),
    ]

    enum CallbackAction: Int {
        case canceled = 0
        case saved = 1
        case deleted = 2
    }

    private weak var delegate: ShowCalendarDelegate?

    private var pendingCall: CAPPluginCall?

    init(delegate: ShowCalendarDelegate?) {
        self.delegate = delegate
        super.init()
    }

    @objc func createEventWithPrompt(_ call: CAPPluginCall) {
        do {
            guard pendingCall == nil else {
                call.reject("Calendar editor is already active")
                return
            }

            guard let delegate = delegate else {
                call.reject("No delegate available to present calendar")
                return
            }

            let event = try CalendarItem(pluginCall: call)

            delegate.present(CalendarViewModel(event: event))

            self.pendingCall = call

        } catch {
            call.reject(String(describing: error), nil, error)
        }
    }

    func didComplete(with action: CallbackAction) {
        guard let call = pendingCall else { return }
        call.resolve(["action": action.rawValue])
        self.pendingCall = nil
    }
}
