import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine


extension DateComponent {
    public static var zero: Self {
        Self(hour: .zero, minute: .zero)
    }
    
    public static var sevenMorning: Self {
        Self(hour: 07, minute: 00)
    }
    
    public static var eightTeenNight: Self {
        Self(hour: 18, minute: .zero)
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
    case onChange
    case response(TimeResponse)
}

public struct YourDayProgressEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let yourDayProgress: (YourDayRequest) -> AnyPublisher<TimeResponse, Never>
    let userDefaults: KeyValueStoreType
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


extension Calendar {
    var minAndHour: (Date?) -> (min: Int, hour: Int)? {
        return {
            guard let date = $0 else { return nil }
            let components = self.dateComponents([.minute, .hour], from: date)
            return (components.minute!, components.hour!)
        }
    }
}


extension Date {
    
}


public let yourDayProgressReducer =
    Reducer<YourDayProgressState, YourDayProgressAction, YourDayProgressEnvironment> { state, action, environment in
    switch action {
    case .onChange:
        
        let startDate = environment.userDefaults
            .object(forKey: "startDate") as? Date
        
        let endDate = environment.userDefaults
            .object(forKey: "endDate") as? Date
        
        let startMinAndHour: (minute: Int, hour: Int) = environment.calendar.minAndHour(startDate) ?? (8, 00)
        
        let endMinAndHour: (minute: Int, hour: Int) =
            environment.calendar.minAndHour(endDate) ?? (18, 00)
                
        return .concatenate(
            environment.yourDayProgress(
                YourDayRequest(
                    date: environment.date(),
                    calendar: environment.calendar,
                    start: YourDayRequest.DateComponent(
                        minute: startMinAndHour.minute,
                        hour: startMinAndHour.hour
                    ),
                    end: YourDayRequest.DateComponent(
                        minute: endMinAndHour.minute,
                        hour: endMinAndHour.hour
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
            statusDescription: percent < 1.0 ? "remaining": "Your day was ended",
            isCircle: style == .circle,
            chosenColor: Color(.systemPink)
        )
    }
}

public struct YourDayProgressView: View {
    
    struct ViewState: Equatable {
        let today: String
        let percentage: NSNumber
        let title: NSAttributedString
        let statusDescription: String
        let isCircle: Bool
        let chosenColor: Color
    }
    
    let store: Store<YourDayProgressState, YourDayProgressAction>
    
    public init(store: Store<YourDayProgressState, YourDayProgressAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            
            HStack(spacing: .py_grid(2)) {
                
                VStack(alignment: .leading) {
                                        
                    Text(viewStore.today)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.preferred(.py_caption2()))
                                                            
                    if viewStore.isCircle {
                        ProgressCircle(
                            color: .pink,
                            lineWidth: .py_grid(2),
                            progress: .constant(viewStore.percentage)
                        ).frame(
                            width: .py_grid(17),
                            height: .py_grid(17)
                        )
                        .offset(y: .py_grid(-5))
                        .saturation(2)
                    } else {
                        ProgressBar(
                            color: .pink,
                            progress: .constant(viewStore.percentage)
                        )
                    }
                                                                    
                    Spacer()
                    
                    HStack(alignment: .lastTextBaseline, spacing: .py_grid(1)) {
                        
                        PLabel(
                            attributedText: .constant(viewStore.title)
                        ).fixedSize()
                                                        
                        Text(viewStore.statusDescription)
                            .font(Font.preferred(.py_caption1()).italic())
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(1)
                    }
                    
                }.padding()
                
            }.onAppear {
                viewStore.send(.onChange)
            }.background(
                RoundedRectangle(
                    cornerRadius: .py_grid(5),
                    style: .continuous
                ).stroke(Color(.white), lineWidth: 1)
                 .shadow(radius: 1)
            )
        }
    }
}

struct YourDayProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
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
                                progress: 1,
                                result: TimeResult(
                                    hour: 0,
                                    minute: 0
                                )
                            )).eraseToAnyPublisher()
                        }
                    )
                )
            )
            .frame(width: 167, height: 167)
            YourDayProgressView(
                store: Store<YourDayProgressState, YourDayProgressAction>(
                    initialState: YourDayProgressState(),
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
            ).preferredColorScheme(.dark)
            .environment(\.sizeCategory, .large)
            .frame(width: 167, height: 167)
        }
    }
}


