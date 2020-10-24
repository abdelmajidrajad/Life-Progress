import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine

public struct SwitchState: Equatable {
    var yearResult: TimeResult
    var todayResult: TimeResult
    var yearPercent: Double
    var todayPercent: Double
    var year: Int
    var style: ProgressStyle
    public init(
        timeResult: TimeResult = .init(),
        dayResult: TimeResult = .init(),
        style: ProgressStyle = .bar,
        yearPercent: Double = .zero,
        todayPercent: Double = .zero,
        year: Int = .zero
    ) {
        self.style = style
        self.yearResult = timeResult
        self.todayResult = dayResult
        self.yearPercent = yearPercent
        self.todayPercent = todayPercent
        self.year = year
    }
}

public enum SwitchAction: Equatable {
    case onAppear
    case setYear(Int)
    case todayResponse(TimeResponse)
    case yearResponse(TimeResponse)
}

public struct SwitchEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let todayProgress: (TodayRequest) -> AnyPublisher<TimeResponse, Never>
    let yearProgress: (YearRequest) -> AnyPublisher<TimeResponse, Never>
}

public let switchReducer =
    Reducer<SwitchState, SwitchAction, SwitchEnvironment> { state, action, environment in
    switch action {
    case .onAppear:
        return .concatenate(
            currentYear(environment.calendar, environment.date())
                .map(SwitchAction.setYear)
                .eraseToEffect(),
            environment.todayProgress(
                TodayRequest(date: environment.date(),
                            calendar: environment.calendar
                )).map(SwitchAction.todayResponse)
                .eraseToEffect(),
            environment.yearProgress(
                YearRequest(
                    date: environment.date(),
                    calendar: environment.calendar,
                    resultType: .short
                )).map(SwitchAction.yearResponse)
                .eraseToEffect()
        )
    case let .todayResponse(response):
        state.todayPercent = response.progress
        state.todayResult = response.result
        return .none
    case let .yearResponse(response):
        state.yearPercent = response.progress
        state.yearResult = response.result
        return .none
    case let .setYear(year):
        state.year = year
        return .none
    }
}

extension SwitchState {
    var view: SwitchProgressView.ViewState {
        SwitchProgressView.ViewState(
            title: "Progress",
            year: "\(year)",
            yearPercent: NSNumber(value: yearPercent),
            todayPercent: NSNumber(value: todayPercent),
            yearTitle: remainingTime(yearResult),
            dayTitle: remainingTime(todayResult),
            isCircle: style == .circle
        )
    }
}

public struct SwitchProgressView: View {
    
    struct ViewState: Equatable {
        let title: String
        let year: String
        let yearPercent: NSNumber
        let todayPercent: NSNumber
        let yearTitle: NSAttributedString
        let dayTitle: NSAttributedString
        let isCircle: Bool
    }
    
    let store: Store<SwitchState, SwitchAction>
    
    public init(store: Store<SwitchState, SwitchAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            HStack(spacing: 8.0) {
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewStore.title)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.headline)
                        Image(systemName: "hourglass")
                    }
                   
                    
                    ZStack {
                        ProgressCircle(
                            color: .green,
                            lineWidth: 8.0,
                            labelHidden: true,
                            progress: .constant(viewStore.yearPercent)
                        ).frame(width: 65, height: 65)
                        .offset(y: -20)
                        
                        ProgressCircle(
                            color: .pink,
                            lineWidth: 8.0,
                            labelHidden: true,
                            progress: .constant(viewStore.todayPercent)
                        ).frame(width: 48, height: 48)
                        .offset(y: -20)
                    }
                                                                        
                    Spacer()
                                                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        PLabel(attributedText: .constant(viewStore.yearTitle))
                        Text("remaining")
                            .font(.caption)
                            .italic()
                    }.foregroundColor(Color.green)
                    .fixedSize()
                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        PLabel(attributedText: .constant(viewStore.dayTitle))
                        Text("remaining")
                            .font(.caption)
                            .italic()
                    }.foregroundColor(Color.pink)
                    .fixedSize()
                    
                    HStack {
                        HStack(spacing: .py_grid(1)) {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 10, height: 10)
                            Text(viewStore.year)
                                .font(.caption)
                        }
                        HStack(spacing: .py_grid(1)) {
                            Circle()
                                .foregroundColor(.pink)
                                .frame(width: 10, height: 10)
                            Text("Today")
                                .font(.caption)
                        }
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                    
                }.padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: 20.0,
                        style: .continuous
                    ).stroke(Color.white)
                    .shadow(radius: 1)
                )
            }.onAppear { viewStore.send(.onAppear) }
            
        }
    }
}

struct SwitchProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchProgressView(
            store: Store<SwitchState, SwitchAction>(
                initialState: SwitchState(style: .bar),
                reducer: switchReducer,
                environment: SwitchEnvironment(
                    calendar: .current,
                    date: Date.init,
                    todayProgress: { _ in
                        Just(TimeResponse(
                            progress: 0.8,
                            result: TimeResult(
                                hour: 12,
                                minute: 9
                            )
                        )).eraseToAnyPublisher()
                    }, yearProgress: { _ in
                        Just(TimeResponse(
                            progress: 0.22,
                            result: TimeResult(
                                day: 200,
                                hour: 22
                            )
                        )).eraseToAnyPublisher()
                    }
                )
            )
        ).frame(width: 169, height: 169)
    }
}
