import Foundation
import UIKit

enum DateTimeFormat {
    case weekdayLongMonthLongDay
    case hour2DigitMinute2Digit
    case monthShortDayNumeri2DigitTime
    case yearNumericMonthShortDayNumeric
    case monthShortDayNumeric
    case dayNumeric
    case weekdayShortYearNumericMonthShortDayNumeric
    case weekdayShortMonthShortDayNumeric
    case yearNumericMonthShortDay2Digit
    case weekdayLong
}

func intlDateTimeFormat(date: Date, format: DateTimeFormat, locale: Locale) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = locale
    dateFormatter.timeZone = TimeZone.current

    switch format {
    case .weekdayLongMonthLongDay:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d", options: 0, locale: locale)
    case .hour2DigitMinute2Digit:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "jj:mm", options: 0, locale: locale)
    case .monthShortDayNumeri2DigitTime:
        let timeFormat = DateFormatter.dateFormat(fromTemplate: "jj:mm", options: 0, locale: locale)
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d, \(timeFormat ?? "")", options: 0, locale: locale)
    case .yearNumericMonthShortDayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d y", options: 0, locale: locale)
    case .monthShortDayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d", options: 0, locale: locale)
    case .dayNumeric:
        dateFormatter.dateFormat = "d"
    case .weekdayShortYearNumericMonthShortDayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE, MMM d, y", options: 0, locale: locale)
    case .weekdayShortMonthShortDayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE, MMM d", options: 0, locale: locale)
    case .yearNumericMonthShortDay2Digit:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM dd, y", options: 0, locale: locale)
    case .weekdayLong:
        dateFormatter.dateFormat = "EEEE"
    }

    return dateFormatter.string(from: date)
}

func formatRelative(date: Date, locale: Locale, ifTodayHideHours: Bool = false) -> String {
    let calendar = Calendar.current
    let now = Date()

    let diffInCalendarDays = calendar.dateComponents([.day], from: now, to: date).day ?? 0

    if diffInCalendarDays > -7 {
        let isToday = calendar.isDateInToday(date)
        if isToday {
            if ifTodayHideHours {
                return tr("custom.today")
            }
            return intlDateTimeFormat(date: date, format: .hour2DigitMinute2Digit, locale: locale)
        }

        let isYesterday = calendar.isDateInYesterday(date)
        if isYesterday {
            return tr("custom.yesterday")
        }

        return intlDateTimeFormat(date: date, format: .weekdayLong, locale: locale)
    }

    return intlDateTimeFormat(date: date, format: .yearNumericMonthShortDayNumeric, locale: locale)
}
