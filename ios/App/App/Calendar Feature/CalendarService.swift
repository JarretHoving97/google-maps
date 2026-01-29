//
//  CalendarService.swift
//  App
//
//  Created by Jarret on 09/01/2026.
//

import EventKit
import Foundation

class CalendarService {

    let store = EKEventStore()

    func createEvent(from event: CalendarItem) -> EKEvent {
        
        let EkEvent = EKEvent(eventStore: store)
        let calendar = Calendar.current

        EkEvent.title = event.title
        EkEvent.startDate = event.startDate
        EkEvent.endDate = event.endDate ?? calendar.date(byAdding: .hour, value: 2, to: event.startDate)
        EkEvent.notes = event.notes
        EkEvent.location = event.location

        // Add a reminder one hour before the event stats
        let alarmOneHourBefore = EKAlarm(
            absoluteDate: calendar.date(
                byAdding: .hour,
                value: -1,
                to: event.startDate
            )!
        )

        // Add a reminder one day before the event starts
        let alarmDayBefore = EKAlarm(
            absoluteDate: calendar.date(
                byAdding: .day,
                value: -1,
                to: event.startDate
            )!
        )

        EkEvent.addAlarm(alarmDayBefore)
        EkEvent.addAlarm(alarmOneHourBefore)

        return EkEvent
    }
}
