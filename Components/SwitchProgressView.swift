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
    var style: ProgressStyle
    public init(
        timeResult: TimeResult = .init(),
        dayResult: TimeResult = .init(),
        style: ProgressStyle = .bar,
        yearPercent: Double = .zero,
        todayPercent: Double = .zero
    ) {
        self.style = style
        self.yearResult = timeResult
        self.todayResult = dayResult
        self.yearPercent = yearPercent
        self.todayPercent = todayPercent
    }
}

public enum SwitchAction: Equatable {
    case onAppear
    case todayResponse(TodayResponse)
    case yearResponse(YearResponse)
}

struct SwitchEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let todayProgress: (TodayRequest) -> AnyPublisher<TodayResponse, Never>
    let yearProgress: (YearRequest) -> AnyPublisher<YearResponse, Never>
}

let switchReducer =
    Reducer<SwitchState, SwitchAction, SwitchEnvironment> { state, action, environment in
    switch action {
    case .onAppear:
        return .concatenate(
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
    }
}

extension SwitchState {
    var view: SwitchProgressView.ViewState {
        SwitchProgressView.ViewState(
            title: "Progress",
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
                    
                    Text(viewStore.title)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.headline)
                    
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
                                                    
                    HStack(alignment: .lastTextBaseline) {
                        PLabel(attributedText: .constant(viewStore.yearTitle))
                            .fixedSize()
                        Text("remaining")
                            .italic()
                    }
                    
                    HStack(alignment: .lastTextBaseline) {
                        PLabel(attributedText: .constant(viewStore.dayTitle))
                            .fixedSize()
                        Text("remaining")
                            .italic()
                    }.foregroundColor(Color.pink.opacity(0.5))
                    
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
                        Just(TodayResponse(
                            progress: 0.8,
                            rest: TimeResult(
                                hour: 12,
                                minute: 9
                            )
                        )).eraseToAnyPublisher()
                    }, yearProgress: { _ in
                        Just(YearResponse(
                            progress: 0.22,
                            result: TimeResult(
                                day: 200,
                                hour: 22
                            )
                        )).eraseToAnyPublisher()
                    }
                )
            )
        )//.frame(width: 169, height: 169)
        .frame(width: 240, height: 240)
    }
}
