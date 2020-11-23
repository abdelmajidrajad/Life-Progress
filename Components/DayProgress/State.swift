import SwiftUI
import ComposableArchitecture
import TimeClient
import Combine

public struct DayState: Equatable {
    public enum ProgressStyle: String, Equatable {
        case bar, circle
        public mutating func toggle() {
            self = self == .bar ? .circle: .bar
        }
    }
    var timeResult: TimeResult
    var percent: Double
    var style: ProgressStyle
    public init(
        timeResult: TimeResult = .init(),
        style: ProgressStyle = .bar,
        percent: Double = .zero
    ) {
        self.style = style
        self.timeResult = timeResult
        self.percent = percent
    }
}

public enum DayAction: Equatable {
    case onChange
    case response(TimeResponse)
    case changeStyle(DayState.ProgressStyle)
}

public struct DayEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let todayProgress: (TodayRequest) -> AnyPublisher<TimeResponse, Never>
    public init(
        calendar: Calendar,
        date: @escaping () -> Date,
        todayProgress: @escaping (TodayRequest) -> AnyPublisher<TimeResponse, Never>
    ) {
        self.calendar = calendar
        self.date = date
        self.todayProgress = todayProgress
    }
}

public let dayReducer =
    Reducer<DayState, DayAction, DayEnvironment> { state, action, environment in
    switch action {
    case .onChange:
        return .concatenate(
            environment.todayProgress(
                TodayRequest(
                    date: environment.date(),
                    calendar: environment.calendar
                )).map(DayAction.response)
                .eraseToEffect()
        )
    case let .response(response):
        state.percent = response.progress
        state.timeResult = response.result
        return .none
    case let .changeStyle(newStyle):
        state.style = newStyle
        return .none
    }
}
