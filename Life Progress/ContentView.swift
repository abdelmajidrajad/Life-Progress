import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import TaskClient
import Components
import CoreData
import Tasks

struct AppState: Equatable {
    var yearState: YearState
    var dayState: DayState
    var switchState: SwitchState
    var tasksState: TasksState
    var yourDayState: YourDayProgressState
    //var settingState: SettingState
    public init(
        yearState: YearState = .init(style: .circle),
        dayState: DayState = .init(style: .circle),
        switchState: SwitchState = .init(),
        tasksState: TasksState = .init(),
        yourDayState: YourDayProgressState = .init()
    ) {
        self.yearState = yearState
        self.dayState = dayState
        self.switchState = switchState
        self.tasksState = tasksState
        self.yourDayState = yourDayState
    }
}

enum AppAction: Equatable {
    case onStart
    case onUpdate(DispatchQueue.SchedulerTimeType)
    case settingButtonTapped
    case year(YearAction)
    case day(DayAction)
    case union(SwitchAction)
    case tasks(TasksAction)
    case yourDay(YourDayProgressAction)
}

struct AppEnvironment {
    let uuid: () -> UUID
    let date: () -> Date
    let calendar: Calendar
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let timeClient: TimeClient
    let taskClient: TaskClient
    let context: NSManagedObjectContext
    let userDefaults: KeyValueStoreType
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    Reducer { state, action, environment in
        switch action {
        case .onStart:
            struct TimerId: Hashable {}
            return Effect.timer(
                id: TimerId(),
                every: .seconds(30.0),
                on: environment.mainQueue
            ).map(AppAction.onUpdate)
            .eraseToEffect()
        case .onUpdate:
            return .concatenate(
                Effect(value: .day(.onChange)),
                Effect(value: .year(.onChange)),
                Effect(value: .tasks(.onChange)),
                Effect(value: .union(.onChange)),
                Effect(value: .yourDay(.onChange))
            )
        case .settingButtonTapped:
            return .none
        default:
            return .none
        }
    },
    dayReducer.pullback(
        state: \.dayState,
        action: /AppAction.day,
        environment: \.day
    ),
    yearReducer.pullback(
        state: \.yearState,
        action: /AppAction.year,
        environment: \.year
    ),
    switchReducer.pullback(
        state: \.switchState,
        action: /AppAction.union,
        environment: \.union
    ),
    yourDayProgressReducer.pullback(
        state: \.yourDayState,
        action: /AppAction.yourDay,
        environment: \.yourDay
    ),
    tasksReducer.pullback(
        state: \.tasksState,
        action: /AppAction.tasks,
        environment: {
            TasksEnvironment(
                date: $0.date,
                calendar: $0.calendar,
                managedContext: $0.context,
                timeClient: $0.timeClient,
                taskClient: $0.taskClient
            )
        }
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
    var union: SwitchEnvironment {
        SwitchEnvironment(
            calendar: calendar,
            date: date,
            todayProgress: timeClient.todayProgress,
            yearProgress: timeClient.yearProgress
        )
    }
    var yourDay: YourDayProgressEnvironment {
        YourDayProgressEnvironment(
            calendar: calendar,
            date: date,
            userDefaults: userDefaults,
            yourDayProgress: timeClient.yourDayProgress
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
                WithViewStore(store) { viewStore in
                    ScrollView {
                        
                        Section(header:
                            ZStack(alignment: .trailing) {
                                Text("Widgets")
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                Button(action: {
                                    viewStore.send(.settingButtonTapped)
                                }, label: {
                                    Image(systemName: "gear")
                                        .foregroundColor(.gray)
                                })
                            }.padding()
                             .font(Font
                                    .preferred(.py_title2()).bold()
                             ).foregroundColor(Color(.lightText))
                        ) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: .py_grid(4)) {
                                    
                                    YourDayProgressView(
                                        store: store.scope(
                                            state: \.yourDayState,
                                            action: AppAction.yourDay)
                                    )
                                    
                                    SwitchProgressView(
                                        store: store.scope(
                                            state: \.switchState,
                                            action: AppAction.union
                                        )
                                    )
                                    
                                    DayProgressView(
                                        store: store.scope(
                                            state: \.dayState,
                                            action: AppAction.day)
                                    )
                                    
                                    YearProgressView(
                                        store: store.scope(
                                            state: \.yearState,
                                            action: AppAction.year)
                                    )
                                
                                                            
                                }.padding(.vertical)
                                .padding(.horizontal, .py_grid(1))
                            }.frame(height: width)
                        }
                        
                        
                        TasksView(store:
                            store.scope(
                                state: \.tasksState,
                                action: AppAction.tasks)
                        )
                                               
                        
                    }.padding(.leading, .py_grid(1))
                    .onAppear {
                        viewStore.send(.onStart)
                    }
                }
            )
        }
    }
}

struct PlusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, .py_grid(5))
            .padding(.vertical, .py_grid(3))
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
                    environment: .midDay
                )
            ).preferredColorScheme(.dark)
        }
    }
}

extension AppEnvironment {
    static var empty: Self {
        Self(
            uuid: UUID.init,
            date: Date.init,
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: .empty,
            taskClient: .empty,
            context: .init(concurrencyType: .privateQueueConcurrencyType),
            userDefaults: UserDefaults()
        )
    }
}

import Combine
extension AppEnvironment {
    static var midDay: Self {
        Self(
            uuid: UUID.init,
            date: { Date(timeIntervalSince1970: 3600 * 24 * 6) },
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: TimeClient(
                yearProgress: { _ in Just(TimeResponse(
                    progress: 0.38,
                    result: TimeResult(
                        hour: 13, minute: 12
                    )
                )).eraseToAnyPublisher()
                }, todayProgress: { _ in
                    Just(TimeResponse(
                    progress: 0.8,
                    result: TimeResult(
                        day: 19, hour: 13
                    )
                )).eraseToAnyPublisher()
                }, taskProgress: { _ in
                    Just(
                        TimeResponse(
                            progress: 0.76,
                            result: TimeResult(
                                //year: 2,
                                //month: 1,
                                day: 7,
                                hour: 12,
                                minute: 44
                            )
                        )
                    ).eraseToAnyPublisher()
                }, yourDayProgress: { _ in
                    Just(
                        TimeResponse(
                            progress: 0.76,
                            result: TimeResult(
                                //year: 2,
                                //month: 1,
                                //day: 7,
                                hour: 6,
                                minute: 44
                            )
                        )
                    ).eraseToAnyPublisher()
                }
                
            ), taskClient:
                TaskClient(tasks: { _ in
                    Just(TaskResponse.tasks([
                        .readBook, .writeBook, .writeBook2
                    ]))
                        .setFailureType(to: TaskFailure.self)
                        .eraseToAnyPublisher()
                }),
            context: .init(concurrencyType: .privateQueueConcurrencyType),
            userDefaults: UserDefaults()
        )
    }
}



struct RoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .font(Font.preferred(.py_title2()).bold().smallCaps())
            .padding(.vertical)
            .padding(.horizontal, .py_grid(6))
            .background(
                RoundedRectangle(cornerRadius: .py_grid(4))                .fill(Color(white: 0.97))
            )
    }
}
