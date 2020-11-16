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
    case onChange
    case response(TimeResponse)
    case changeStyle(ProgressStyle)
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

extension DayState {
    var view: DayProgressView.ViewState {
        DayProgressView.ViewState(
            today: "Today",
            percentage: NSNumber(value: percent),
            result: timeResult,
                //.string(widgetStyle),
            isCircle: style == .circle
        )
    }
}

func buildText(from result: TimeResult) -> some View {
    return  result.component
        .filter { $0 != .empty }
        .map(label(from:))
        .reduce(Text(""), +)
}


func label
    (from component: TimeResult.Component)
-> Text {
    return Text(String(component.value))
            .font(.preferred(.py_headline()))
            .foregroundColor(Color(.label))
        + Text(component.string(true))
            .font(.preferred(UIFont.py_caption2().lowerCaseSmallCaps))
            .foregroundColor(Color(.secondaryLabel))
}


public struct DayProgressView: View {
    
    struct ViewState: Equatable {
        let today: String
        let percentage: NSNumber
        let result: TimeResult
        let isCircle: Bool
    }
    
    let store: Store<DayState, DayAction>
    
    public init(
    store: Store<DayState, DayAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store.scope(state: \.view)) { viewStore in
            HStack(spacing: .py_grid(2)) {
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
                    HStack(
                        alignment: .lastTextBaseline,
                        spacing: .py_grid(1)) {
                        
                        buildText(from: viewStore.result)
                            .layoutPriority(1)
                        
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                            .lineLimit(1)
                    }
                }.padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: .py_grid(5),
                        style: .continuous
                    ).stroke(Color.white.opacity(0.1))
                    .shadow(radius: 1)
                )
            }.onAppear { viewStore.send(.onChange) }
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
        
        buildText(from: TimeResult(
                    year: 10,
                    month: 20,
                    day: 20,
                    hour: 2,
                    minute: 9
        ))
        
        
    }
}

