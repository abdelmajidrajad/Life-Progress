import Foundation

extension Calendar {
    public func dayEnd(of today: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: self.startOfDay(for: today))!
    }
}


public struct DateComponent: Equatable {
    public let hour, minute: Int
    public init(
        hour: Int,
        minute: Int
    ) {
        self.hour = hour
        self.minute = minute
    }
}
