import Foundation

extension Calendar {
    public func dayEnd(of today: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: self.startOfDay(for: today))!
    }
}
