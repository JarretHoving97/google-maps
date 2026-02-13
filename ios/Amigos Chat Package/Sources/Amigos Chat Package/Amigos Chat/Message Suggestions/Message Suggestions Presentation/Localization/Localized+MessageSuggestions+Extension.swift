//
//  Localized+MessageSuggestions+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 12/02/2026.
//

import Foundation

extension Localized {

    enum MessageSuggestions {

        static var table: String { "MessageSuggestions" }

        // MARK: - 48h window
        static var planCTA: String {
            localized("message_suggestion.plan.cta", table: table)
        }

        static var whenFull: String {
            localized("message_suggestion.when.full", table: table)
        }

        static var whereFull: String {
            localized("message_suggestion.where.full", table: table)
        }

        static var whenShort: String {
            localized("message_suggestion.when.short", table: table)
        }

        static var timeFull: String {
            localized("message_suggestion.time.full", table: table)
        }

        // MARK: - 9h window
        static var funGroupAlready: String {
            localized("message_suggestion.fun_group.already", table: table)
        }

        static var whoFirstTime: String {
            localized("message_suggestion.who_first.time", table: table)
        }

        static var excitedToMeet: String {
            localized("message_suggestion.excited.to_meet", table: table)
        }

        static var cantWaitShort: String {
            localized("message_suggestion.cant_wait.short", table: table)
        }

        static var firstTimeHosting: String {
            localized("message_suggestion.first_time.hosting", table: table)
        }

        // MARK: - 3h window
        static var arrivalTenBefore: String {
            localized("message_suggestion.arrival.ten_before", table: table)
        }

        static var whenArrival: String {
            localized("message_suggestion.when.arrival", table: table)
        }

        static var waitingOutside: String {
            localized("message_suggestion.waiting.outside", table: table)
        }

        static var whereMeet: String {
            localized("message_suggestion.where.meet", table: table)
        }

        static var delayedRunningLate: String {
            localized("message_suggestion.delayed.running_late", table: table)
        }

    }
}
