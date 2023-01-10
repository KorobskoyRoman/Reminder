//
//  Date+Today.swift
//  Reminder
//
//  Created by Roman Korobskoy on 09.01.2023.
//

import Foundation

extension Date {
    var dayAndTimeText: String {
        let timeText = formatted(date: .omitted, time: .shortened)

        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
        } else if Locale.current.calendar.isDateInTomorrow(self) {
            let timeFormat = NSLocalizedString("Tomorow at %@", comment: "Tomorrow at time format string")
            return String(format: timeFormat, timeText)
        } else {
            let dateText = formatted(.dateTime.month(.abbreviated).day())
            let dateAndTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format string")
            return String(format: dateAndTimeFormat, dateText, timeText)
        }
    }

    var dayText: String {
        if Locale.current.calendar.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today due date description")
        } else if Locale.current.calendar.isDateInTomorrow(self) {
            return NSLocalizedString("Tomorrow", comment: "Tomorrow due date description")
        } else {
            return formatted(.dateTime.month().day().weekday(.wide))
        }
    }
}
