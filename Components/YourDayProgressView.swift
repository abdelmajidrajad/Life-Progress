import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine


extension DateComponent {
    public static var zero: Self {
        Self(hour: .zero, minute: .zero)
    }
}

public struct DateComponent: Equatable {
    let hour, minute: Int
    public init(
        hour: Int,
        minute: Int
    ) {
        self.hour = hour
        self.minute = minute
    }
}

public struct YourDayProgressState: Equatable {
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

public enum YourDayProgressAction: Equatable {
    case onAppear
    case response(TimeResponse)
}

public struct YourDayProgressEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let yourDayProgress: (YourDayRequest) -> AnyPublisher<TimeResponse, Never>
        
    var userDefaults: KeyValueStoreType
    
    public init(
        calendar: Calendar,
        date: @escaping () -> Date,
        userDefaults: KeyValueStoreType,
        yourDayProgress: @escaping (YourDayRequest) -> AnyPublisher<TimeResponse, Never>
    ) {
        self.calendar = calendar
        self.userDefaults = userDefaults
        self.date = date
        self.yourDayProgress = yourDayProgress
    }
}

public let yourDayProgressReducer =
    Reducer<YourDayProgressState, YourDayProgressAction, YourDayProgressEnvironment> { state, action, environment in
    switch action {
    case .onAppear:
        
        let startDate = environment.userDefaults
            .object(forKey: "startDate") as? DateComponent
            ?? .zero
        
        let endDate = environment.userDefaults
            .object(forKey: "endDate") as? DateComponent
            ?? .zero
        
        return .concatenate(
            environment.yourDayProgress(
                YourDayRequest(
                    date: environment.date(),
                    calendar: environment.calendar,
                    start: YourDayRequest.DateComponent(
                        minute: startDate.minute,
                        hour: startDate.hour
                    ),
                    end: YourDayRequest.DateComponent(
                        minute: endDate.minute,
                        hour: endDate.hour
                    )
                )
            ).map(YourDayProgressAction.response)
            .eraseToEffect()
        )
    case let .response(response):
        state.percent = response.progress
        state.timeResult = response.result
        return .none
    }
}

extension YourDayProgressState {
    var view: YourDayProgressView.ViewState {
        YourDayProgressView.ViewState(
            today: "Your Day",
            percentage: NSNumber(value: percent),
            title: timeResult.string(widgetStyle),
            isCircle: style == .circle
        )
    }
}

public struct YourDayProgressView: View {
    
    struct ViewState: Equatable {
        let today: String
        let percentage: NSNumber
        let title: NSAttributedString
        let isCircle: Bool
    }
    
    let store: Store<YourDayProgressState, YourDayProgressAction>
    
    public init(store: Store<YourDayProgressState, YourDayProgressAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            HStack(spacing: 8.0) {
                
                VStack(alignment: .leading) {
                                        
                    Text(viewStore.today)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.preferred(.py_caption2()))
                                                            
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
                
            }.onAppear {
                viewStore.send(.onAppear)
            }
            
        }
    }
}

struct YourDayProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YourDayProgressView(
            store: Store<YourDayProgressState, YourDayProgressAction>(
                initialState: YourDayProgressState(style: .circle),
                reducer: yourDayProgressReducer,
                environment: YourDayProgressEnvironment(
                    calendar: .current,
                    date: Date.init,
                    userDefaults: UserDefaults(),
                    yourDayProgress: { _ in
                        Just(TimeResponse(
                            progress: 0.45,
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


