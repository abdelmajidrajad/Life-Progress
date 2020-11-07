import SwiftUI
import ComposableArchitecture
import Tasks
import Components


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