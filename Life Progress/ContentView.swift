import SwiftUI
import ComposableArchitecture
import TimeClient
import Components
import CoreData

struct AppState: Equatable {
    var yearState: YearState
    var dayState: DayState
    public init(
        yearState: YearState = .init(style: .circle),
        dayState: DayState = .init()
    ) {
        self.yearState = yearState
        self.dayState = dayState
    }
}

enum AppAction: Equatable {
    case year(YearAction)
    case day(DayAction)
}

struct AppEnvironment {
    let uuid: () -> UUID
    let date: () -> Date
    let calendar: Calendar
    let timeClient: TimeClient
    let context: NSManagedObjectContext
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    dayReducer.pullback(
        state: \.dayState,
        action: /AppAction.day,
        environment: \.day
    ),
    yearReducer.pullback(
        state: \.yearState,
        action: /AppAction.year,
        environment: \.year
    )
)

extension AppEnvironment {
    var day: DayEnvironment {
        DayEnvironment(
            calendar: calendar,
            date: date,
            todayProgress: timeClient.todayProgress
        )
    }
}

extension AppEnvironment {
    var year: YearEnvironment {
        YearEnvironment(
            calendar: calendar,
            date: date,
            yearProgress: timeClient.yearProgress
        )
    }
}


struct ContentView: View {
    
    let store: Store<AppState, AppAction>
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
    }
    
    var body: some View {
        GeometryReader { proxy -> AnyView in
            let width = proxy.size.width * 0.5 - 8.0
            return AnyView(
                HStack {
                    
                    DayProgressView(
                        store: store.scope(
                            state: \.dayState,
                            action: AppAction.day)
                    ).frame(width: width, height: width)
                    
                    YearProgressView(
                        store: store.scope(
                            state: \.yearState,
                            action: AppAction.year)
                    ).frame(width: width, height: width)
                    
                }.padding(.leading, 4)
            )
        }
    }
}

struct PlusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12.0)
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(Color.white)
                    .shadow(color: Color(white: 0.95), radius: 1)
            )
    }
}

let lineWidth: CGFloat = 8.0
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(
                store: Store<AppState, AppAction>(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: .midDay)
            )
        }
    }
}

extension AppEnvironment {
    static var empty: Self {
        Self(
            uuid: UUID.init,
            date: Date.init,
            calendar: .current,
            timeClient: .empty,
            context: .init(concurrencyType: .privateQueueConcurrencyType)
        )
    }
}

import Combine
extension AppEnvironment {
    static var midDay: Self {
        Self(
            uuid: UUID.init,
            date: Date.init,
            calendar: .current,
            timeClient: TimeClient(
                yearProgress: { _ in Just(TimeResponse(
                    progress: 0.38,
                    result: TimeResult(
                        hour: 13, minute: 12
                    )
                )).eraseToAnyPublisher()
                }, todayProgress: { _ in Just(TimeResponse(
                    progress: 0.8,
                    result: TimeResult(
                        day: 19, hour: 13
                    )
                )).eraseToAnyPublisher()
                }
                
            ),
            context: .init(concurrencyType: .privateQueueConcurrencyType)
        )
    }
}


