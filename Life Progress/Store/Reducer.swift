import SwiftUI
import ComposableArchitecture
import Tasks
import Settings
import Components


let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    Reducer { state, action, environment in
        switch action {
        case .onStart:
            struct TimerId: Hashable {}
            return Effect.timer(
                id: TimerId(),
                every: .seconds(1.0),
                on: environment.mainQueue
            ).map(AppAction.onUpdate)
            .eraseToEffect()
        case .onUpdate:
            return .concatenate(
                Effect(value: .day(.onChange)),
                Effect(value: .year(.onChange)),
                Effect(value: .life(.onChange)),
                Effect(value: .union(.onChange)),
                Effect(value: .yourDay(.onChange))
            )
        case .settingButtonTapped:
            state.settingState = SettingState()
            return .none
        case .viewDismissed:
            state.settingState = nil
            state.shareState = nil
            return .none
        case .shareButtonTapped:
            state.shareState = ShareState(
                yearState: state.yearState,
                dayState: state.dayState,
                switchState: state.switchState,
                yourDayState: state.yourDayState,
                life: state.life
            )
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
    lifeReducer.pullback(
        state: \.life,
        action: /AppAction.life,
        environment: \.life
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
                uuid: $0.uuid,
                date: $0.date,
                calendar: $0.calendar,
                managedContext: $0.context,
                timeClient: $0.timeClient,
                taskClient: $0.taskClient
            )
        }
    ),
    settingReducer.optional().pullback(
        state: \.settingState,
        action: /AppAction.settings,
        environment: \.settings
    ),
    shareReducer.optional().pullback(
        state: \.shareState,
        action: /AppAction.share,
        environment: \.share
    )
)


extension AppEnvironment {
    var tasks: TasksEnvironment {
        TasksEnvironment(
            uuid: self.uuid,
            date: self.date,
            calendar: self.calendar,
            managedContext: self.context,
            timeClient: self.timeClient,
            taskClient: self.taskClient
        )
    }
}

extension AppEnvironment {
    var life: LifeEnvironment {
        LifeEnvironment(
            userDefaults: userDefaults,
            lifeProgress: timeClient.lifeProgress
        )
    }
}
