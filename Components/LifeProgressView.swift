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
    let userDefaults: KeyValueStoreType
    let lifeProgress: (LifeRequest) -> AnyPublisher<TimeResponse, Never>
    public init(
        calendar: Calendar,
        date: @escaping () -> Date,
        userDefaults: KeyValueStoreType,
        lifeProgress: @escaping (LifeRequest) -> AnyPublisher<TimeResponse, Never>
    ) {
        self.calendar = calendar
        self.date = date
        self.userDefaults = userDefaults
        self.lifeProgress = lifeProgress
    }
}

public let lifeReducer =
    Reducer<LifeProgressState, LifeProgressAction, LifeEnvironment> { state, action, environment in
    switch action {
    case .onChange:
        
        let birthDate = environment.userDefaults.object(forKey: "birthDate") as? Date
        
        let currentAge = environment.calendar
            .dateComponents([.year],
                            from: birthDate ?? environment.date(),
                            to: environment.date()).year ?? 5
                                    
        return environment.lifeProgress(
            LifeRequest(
                date: environment.date(),
                calendar: environment.calendar,
                expectedLife: environment.userDefaults.integer(forKey: "life"),
                age: currentAge
            )).map(LifeProgressAction.response)
              .eraseToEffect()
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
            percentage: percent <= 1
                ? NSNumber(value: percent)
                : 1.0
            ,
            status: percent <= 1
                ? percent == 1 ?
            "configure on settings": "remaining"
                : "never too late",
            result: timeResult,
            isCircle: style == .circle
        )
    }
}

public struct LifeProgressView: View {
    
    struct ViewState: Equatable {
        let today: String
        let percentage: NSNumber
        let status: String
        let result: TimeResult
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
                        .offset(y: .py_grid(-7))
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
                        
                        Text(viewStore.status)
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
                    ).fill(Color(.systemBackground))
                    .shadow(color: Color.pink.opacity(0.2), radius: 3)
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
                        calendar: Calendar.current,
                        date: Date.init,
                        userDefaults: TestUserDefault(),
                        lifeProgress: { request in
                            Just(TimeResponse(
                                progress: Double(request.age) / Double(request.expectedLife),
                                result: TimeResult(
                                    year: request.expectedLife - request.age
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
                        calendar: Calendar.current,
                        date: Date.init,
                        userDefaults: TestUserDefault(),
                        lifeProgress: { _ in
                            Just(TimeResponse(
                                progress: 0.2,
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

