import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine


public struct LifeProgressState: Equatable {
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

public enum LifeProgressAction: Equatable {
    case onChange
    case response(TimeResponse)
}

public struct LifeEnvironment {
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

public let lifeReducer =
    Reducer<LifeProgressState, LifeProgressAction, LifeEnvironment> { state, action, environment in
    switch action {
    case .onChange:
        return .concatenate(
            environment.todayProgress(
                TodayRequest(
                    date: environment.date(),
                    calendar: environment.calendar
                )).map(LifeProgressAction.response)
                .eraseToEffect()
        )
    case let .response(response):
        state.percent = response.progress
        state.timeResult = response.result
        return .none
    }
}

extension LifeProgressState {
    var view: LifeProgressView.ViewState {
        LifeProgressView.ViewState(
            today: "heart.fill",
            percentage: NSNumber(value: percent),
            title: timeResult.string(widgetStyle),
            isCircle: style == .circle
        )
    }
}

public struct LifeProgressView: View {
    
    struct ViewState: Equatable {
        let today: String
        let percentage: NSNumber
        let title: NSAttributedString
        let isCircle: Bool
    }
    
    let store: Store<LifeProgressState, LifeProgressAction>
    
    public init(
        store: Store<LifeProgressState, LifeProgressAction>) {
            self.store = store
    }
    
    public var body: some View {
        WithViewStore(store.scope(state: \.view)) { viewStore in
            HStack(spacing: .py_grid(2)) {
                
                VStack(alignment: .leading) {
                    
                    Image(systemName: viewStore.today)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.title)
                        .foregroundColor(.pink)
                    
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
                        PLabel(
                            attributedText:
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
                        cornerRadius: .py_grid(5),
                        style: .continuous
                    ).stroke(Color.white)
                    .shadow(radius: 1)
                )
            }.onAppear { viewStore.send(.onChange) }
        }
    }
}

struct LifeProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LifeProgressView(
                store: Store<LifeProgressState, LifeProgressAction>(
                    initialState: LifeProgressState(style: .circle),
                    reducer: lifeReducer,
                    environment: LifeEnvironment(
                        calendar: .current,
                        date: Date.init,
                        todayProgress: { _ in
                            Just(TimeResponse(
                                progress: 0.8,
                                result: TimeResult(
                                    year: 23
                                )
                            )).eraseToAnyPublisher()
                        }
                    )
                )
            ).frame(width: 141, height: 141)
            LifeProgressView(
                store: Store<LifeProgressState, LifeProgressAction>(
                    initialState: LifeProgressState(style: .bar),
                    reducer: lifeReducer,
                    environment: LifeEnvironment(
                        calendar: .current,
                        date: Date.init,
                        todayProgress: { _ in
                            Just(TimeResponse(
                                progress: 0.8,
                                result: TimeResult(
                                    year: 23
                                )
                            )).eraseToAnyPublisher()
                        }
                    )
                )
            ).preferredColorScheme(.dark).frame(width: 141, height: 141)
        }
    }
}

