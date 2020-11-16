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
    case onChange
    case setYear(Int)
    case todayResponse(TimeResponse)
    case yearResponse(TimeResponse)
}

public struct SwitchEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let todayProgress: (TodayRequest) -> AnyPublisher<TimeResponse, Never>
    let yearProgress: (YearRequest) -> AnyPublisher<TimeResponse, Never>
    
    public init(
        calendar: Calendar,
        date: @escaping () -> Date,
        todayProgress: @escaping (TodayRequest) -> AnyPublisher<TimeResponse, Never>,
        yearProgress: @escaping (YearRequest) -> AnyPublisher<TimeResponse, Never>
    ) {
        self.calendar = calendar
        self.date = date
        self.todayProgress = todayProgress
        self.yearProgress = yearProgress
    }
    
}

public let switchReducer =
    Reducer<SwitchState, SwitchAction, SwitchEnvironment> { state, action, environment in
        switch action {
        case .onChange:
            return .concatenate(
                environment
                    .calendar
                    .currentYear(
                        environment.date()
                    )
                .map(SwitchAction.setYear)
                .eraseToEffect(),
                environment.todayProgress(
                    TodayRequest(
                        date: environment.date(),
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
            result: yearResult,
            dayTitle: todayResult.string(taskCellStyle),
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
        let result: TimeResult
        let dayTitle: NSAttributedString
        let isCircle: Bool
    }
    
    let store: Store<SwitchState, SwitchAction>
    
    public init(store: Store<SwitchState, SwitchAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            
            HStack(spacing: .py_grid(2)) {
                
                VStack(alignment: .leading) {
                                            
                    HStack(alignment: .top) {
                        ZStack {
                            ProgressCircle(
                                color: .green,
                                lineWidth: .py_grid(3),
                                labelHidden: true,
                                progress: .constant(viewStore.yearPercent)
                            ).frame(
                                width: .py_grid(16),
                                height: .py_grid(16)
                            )
                            
                            ProgressCircle(
                                color: .pink,
                                lineWidth: .py_grid(3),
                                labelHidden: true,
                                progress: .constant(viewStore.todayPercent)
                            ).frame(
                                width: .py_grid(10),
                                height: .py_grid(10)
                            )
                        }
                        
                        Image(systemName: "hourglass")
                            .frame(
                                maxWidth: .infinity,
                                alignment: .trailing
                            )
                            .foregroundColor(.pink)
                            .font(.preferred(.py_title2()))
                    }
            
                    Spacer(minLength: .zero)                    
                    
                    HStack {
                        HStack(spacing: .py_grid(1)) {
                            Circle()
                                .foregroundColor(.green)
                                .frame(
                                    width: .py_grid(2),
                                    height: .py_grid(2))
                            Text(viewStore.year)
                                .font(Font.preferred(.py_caption2()))
                        }
                        HStack(spacing: .py_grid(1)) {
                            Circle()
                                .foregroundColor(.pink)
                                .frame(
                                    width: .py_grid(2),
                                    height: .py_grid(2)
                                )
                            Text("Today")
                                .font(Font.preferred(.py_caption2()))
                        }
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                    
                                                    
                    HStack(
                        alignment: .lastTextBaseline,
                        spacing: 2)
                    {
                        buildText(from: viewStore.result)
                        Text("left")
                            .font(Font.preferred(.py_caption2()).italic())
                            .foregroundColor(Color.green)
                    }
                    .fixedSize()
                                        
                    
                }.padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: .py_grid(5),
                        style: .continuous
                    ).stroke(Color.white)
                     .shadow(radius: 1)
                )
            }.onAppear {
                viewStore.send(.onChange)
            }
            
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
                            progress: 0.56,
                            result: TimeResult(
                                hour: 12,
                                minute: 9
                            )
                        )).eraseToAnyPublisher()
                    }, yearProgress: { _ in
                        Just(
                            TimeResponse(
                                progress: 0.38,
                                result: TimeResult(
                                    day: 200,
                                    hour: 22,
                                    minute: 12
                                )
                        )).eraseToAnyPublisher()
                    }
                )
            )
        )
        .preferredColorScheme(.dark)
        .frame(width: 169, height: 169)

    }
}
