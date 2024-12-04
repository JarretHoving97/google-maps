// swiftlint:disable all

import Foundation
import UIKit

enum DateTimeFormat {
    case weekdayLong_MonthLong_DayNumeric
    case hour2Digit_Minute2Digit
    case monthShort_DayNumeric_Hour2Digit_Minute2Digit
    case yearNumeric_MonthShort_DayNumeric
    case monthShort_DayNumeric
    case dayNumeric
    case weekdayShort_YearNumeric_MonthShort_DayNumeric
    case weekdayShort_MonthShort_DayNumeric
    case yearNumeric_MonthShort_Day2Digit
    case weekdayLong
}

func intlDateTimeFormat(date: Date, format: DateTimeFormat, locale: Locale) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = locale
    dateFormatter.timeZone = TimeZone.current

    switch format {
    case .weekdayLong_MonthLong_DayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d", options: 0, locale: locale)
    case .hour2Digit_Minute2Digit:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "jj:mm", options: 0, locale: locale)
    case .monthShort_DayNumeric_Hour2Digit_Minute2Digit:
        let timeFormat = DateFormatter.dateFormat(fromTemplate: "jj:mm", options: 0, locale: locale)
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d, \(timeFormat ?? "")", options: 0, locale: locale)
    case .yearNumeric_MonthShort_DayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d y", options: 0, locale: locale)
    case .monthShort_DayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d", options: 0, locale: locale)
    case .dayNumeric:
        dateFormatter.dateFormat = "d"
    case .weekdayShort_YearNumeric_MonthShort_DayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE, MMM d, y", options: 0, locale: locale)
    case .weekdayShort_MonthShort_DayNumeric:
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE, MMM d", options: 0, locale: locale)
    case .yearNumeric_MonthShort_Day2Digit:
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
            return intlDateTimeFormat(date: date, format: .hour2Digit_Minute2Digit, locale: locale)
        }

        let isYesterday = calendar.isDateInYesterday(date)
        if isYesterday {
            return tr("custom.yesterday")
        }

        return intlDateTimeFormat(date: date, format: .weekdayLong, locale: locale)
    }

    return intlDateTimeFormat(date: date, format: .yearNumeric_MonthShort_DayNumeric, locale: locale)
}
