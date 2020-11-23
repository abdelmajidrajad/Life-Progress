import Foundation

public let endOfDay: (Date, Calendar) -> Date = { today, calendar in
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return calendar.date(byAdding: components, to: calendar.startOfDay(for: today))!
}

