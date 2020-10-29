import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine

public struct DayState: Equatable {
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
    case onAppear
    case response(TimeResponse)
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
    case .onAppear:
        return .concatenate(
            environment.todayProgress(
                TodayRequest(date: environment.date(),
                            calendar: environment.calendar
                )).map(DayAction.response)
                .eraseToEffect()
        )
    case let .response(response):
        state.percent = response.progress
        state.timeResult = response.result
        return .none
    }
}

extension DayState {
    var view: DayProgressView.ViewState {
        DayProgressView.ViewState(
            today: "Today",
            percentage: NSNumber(value: percent),
            title: timeResult.string(widgetStyle),
            isCircle: style == .circle
        )
    }
}

public struct DayProgressView: View {
    
    struct ViewState: Equatable {
        let today: String
        let percentage: NSNumber
        let title: NSAttributedString
        let isCircle: Bool
    }
    
    let store: Store<DayState, DayAction>
    
    public init(store: Store<DayState, DayAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            HStack(spacing: 8.0) {
                
                VStack(alignment: .leading) {
                                        
                    Text(viewStore.today)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.footnote)
                                                            
                    if viewStore.isCircle {
                        ProgressCircle(
                            color: .pink,
                            lineWidth: .py_grid(3),
                            progress: .constant(viewStore.percentage)
                        ).frame(width: .py_grid(17), height: .py_grid(17))
                        .offset(y: -20)
                    } else {
                        ProgressBar(
                            color: .pink,
                            progress: .constant(viewStore.percentage)
                        )
                    }
                                                    
                    Spacer()
                                                    
                    HStack(alignment: .lastTextBaseline, spacing: .py_grid(1)) {
                        
                        PLabel(attributedText:
                                .constant(viewStore.title)
                        ).fixedSize()
                            
                            
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                            .lineLimit(1)
                            
                    }
                   
                    
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

struct DayProgressView_Previews: PreviewProvider {
    static var previews: some View {
        DayProgressView(
            store: Store<DayState, DayAction>(
                initialState: DayState(style: .bar),
                reducer: dayReducer,
                environment: DayEnvironment(
                    calendar: .current,
                    date: Date.init,
                    todayProgress: { _ in
                        Just(TimeResponse(
                            progress: 0.8,
                            result: TimeResult(
                                hour: 8,
                                minute: 2
                            )
                        )).eraseToAnyPublisher()
                    }
                )
            )
        ).frame(width: 141, height: 141)
    }
}

