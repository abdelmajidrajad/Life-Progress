import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine

public enum ProgressStyle: Equatable { case bar, circle }

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
    case response(TodayResponse)
}

struct DayEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let todayProgress: (TodayRequest) -> AnyPublisher<TodayResponse, Never>
}

let dayReducer =
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
            title: remainingTime(timeResult),
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
                        .font(.title)
                                                            
                    if viewStore.isCircle {
                        ProgressCircle(
                            color: .pink,
                            lineWidth: 12.0,
                            progress: .constant(viewStore.percentage)
                        ).frame(width: 80, height: 80)
                        .offset(y: -40)
                    } else {
                        ProgressBar(
                            color: .green,
                            progress: .constant(viewStore.percentage)
                        )
                    }
                                                    
                    Spacer()
                                                    
                    HStack(alignment: .lastTextBaseline) {
                        
                        PLabel(attributedText: .constant(viewStore.title))
                            
                        Text("remaining")
                            .foregroundColor(.gray)
                            .italic()
                            
                    }.fixedSize()
                    
                }.padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: 20.0,
                        style: .continuous
                    ).fill(Color.white)
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
                initialState: DayState(style: .circle),
                reducer: dayReducer,
                environment: DayEnvironment(
                    calendar: .current,
                    date: Date.init,
                    todayProgress: { _ in
                        Just(TodayResponse(
                            progress: 0.8,
                            rest: TimeResult(
                                hour: 08,
                                minute: 56
                            )
                        )).eraseToAnyPublisher()
                    }
                )
            )
        ).frame(width: 141, height: 141)
    }
}
