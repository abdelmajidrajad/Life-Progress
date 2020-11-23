import Combine
import Foundation

// how many days till the end of year
// how many hours till the end of day // config your day add sleep time
// how many weeks till the end of the year
// how much hours/minutes/weeks/months till the end of a specific task .

public struct TodayRequest {
    public let date: Date
    public let calendar: Calendar
    public init(
        date: Date,
        calendar: Calendar
    ) {
        self.date = date
        self.calendar = calendar
    }
}

public struct YourDayRequest {
    public struct DateComponent {
        public let minute: Int
        public let hour: Int
        public init(
            minute: Int,
            hour: Int
        ) {
            self.minute = minute
            self.hour = hour
        }
    }
    public let date: Date
    public let calendar: Calendar
    public let start: DateComponent
    public let end: DateComponent
    public init(
        date: Date,
        calendar: Calendar,
        start: DateComponent,
        end: DateComponent
    ) {
        self.date = date
        self.calendar = calendar
        self.start = start
        self.end = end
    }
}


public struct TimeResponse: Equatable {
    public let progress: TimeInterval
    public let result: TimeResult
    public init(
        progress: TimeInterval,
        result: TimeResult
    ) {
        self.progress = progress
        self.result = result
    }
}

public struct YearRequest {
    public enum ´Type´ {
        case short
        case long
    }
    public let date: Date
    public let calendar: Calendar
    public let resultType: ´Type´
    public init(
        date: Date,
        calendar: Calendar,
        resultType: ´Type´
    ) {
        self.date = date
        self.calendar = calendar
        self.resultType = resultType
    }
}

extension YearRequest.´Type´ {
    public var components: Set<Calendar.Component> {
        switch self {
        case .short:
            return [.day, .hour, .minute]
        case .long:
            return [.year, .month, .day, .hour, .minute]
        }
    }
}

public struct TimeResult: Equatable {            
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public init(
        year: Int = .zero,
        month: Int = .zero,
        day: Int = .zero,
        hour: Int = .zero,
        minute: Int = .zero
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
    }
    
    public enum Component: Equatable {
        case year(Int)
        case month(Int)
        case hour(Int)
        case minute(Int)
        case day(Int)
        case empty
    }
    
}

extension TimeResult.Component {
    public func string(_ short: Bool = false) -> String {
        switch self {
        case .day:
            return short ? "d": "day"
        case .year:
            return short ? "y": "year"
        case .month:
            return short ? "m": "month"
        case .hour:
            return short ? "h": "hour"
        case .minute:
            return short ? "min": "minute"
        case .empty:
            return ""
        }
    }
}

extension TimeResult.Component {
    public var value: Int {
        switch self {
        case let .day(value):
            return value
        case let .year(value):
            return value
        case let .month(value):
            return value
        case let .hour(value):
            return value
        case let .minute(value):
            return value
        case .empty:
            return .zero
        }
    }
}


extension TimeResult {
    public var component: [TimeResult.Component] {
        [
            year == 0 ? .empty: .year(year),
            month == 0 ? .empty: .month(month),
            day == 0 ? .empty: .day(day),
            hour == 0 ? .empty: .hour(hour),
            minute == 0 ? .empty: .minute(minute),
        ]
    }
}




//var componentResult: (TimeResult) -> [] { }

extension TimeResult {
    public static var zero: TimeResult {
        TimeResult()
    }
}

public struct WeekRequest {
    public let date: Date
    public let calendar: Calendar
    public init(
        date: Date,
        calendar: Calendar
    ) {
        self.date = date
        self.calendar = calendar
    }
}

public struct LifeRequest {
    public let expectedLife: Int
    public let age: Int
    public init(
        expectedLife: Int,
        age: Int
    ) {
        self.expectedLife = expectedLife
        self.age = age
    }
}


public struct WeekResponse: Equatable {
    public let currentWeek: Int
    public let remainingWeeks: Int
    public let progress: TimeInterval
    public init(
        currentWeek: Int,
        remainingWeeks: Int,
        progress: TimeInterval
    ) {
        self.currentWeek = currentWeek
        self.remainingWeeks = remainingWeeks
        self.progress = progress
    }
}

public struct ProgressTaskRequest {
    public let currentDate: Date
    public let calendar: Calendar
    public let startAt: Date
    public let endAt: Date
    public init(
        currentDate: Date,
        calendar: Calendar,        
        startAt: Date,
        endAt: Date
    ) {
        self.currentDate = currentDate
        self.calendar = calendar
        self.startAt = startAt
        self.endAt = endAt
    }
}


public struct TimeClient {
    public let yearProgress:
        (YearRequest) -> AnyPublisher<TimeResponse, Never>
    public let todayProgress:
        (TodayRequest) -> AnyPublisher<TimeResponse, Never>
    public let weekProgress:
        (WeekRequest) -> AnyPublisher<WeekResponse, Never>
    public let taskProgress:
        (ProgressTaskRequest) -> AnyPublisher<TimeResponse, Never>
    public let yourDayProgress:
        (YourDayRequest) -> AnyPublisher<TimeResponse, Never>
    public let lifeProgress:
        (LifeRequest) -> AnyPublisher<TimeResponse, Never>
    public init(
        yearProgress: @escaping (YearRequest) -> AnyPublisher<TimeResponse, Never> = { _ in .none },
        todayProgress: @escaping (TodayRequest) -> AnyPublisher<TimeResponse, Never> = { _ in .none },
        weekProgress: @escaping (WeekRequest) -> AnyPublisher<WeekResponse, Never> = { _ in .none },
        taskProgress: @escaping (ProgressTaskRequest) -> AnyPublisher<TimeResponse, Never> = { _ in .none },
        yourDayProgress: @escaping (YourDayRequest) -> AnyPublisher<TimeResponse, Never> = { _ in .none },
        lifeProgress:
            @escaping (LifeRequest) -> AnyPublisher<TimeResponse, Never> = { _ in .none }
    ) {
        self.yearProgress = yearProgress
        self.todayProgress = todayProgress
        self.weekProgress = weekProgress
        self.taskProgress = taskProgress
        self.yourDayProgress = yourDayProgress
        self.lifeProgress = lifeProgress
    }
}


