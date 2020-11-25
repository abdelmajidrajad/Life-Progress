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
            return Effect
                .timer(id: TimerId(),
                       every: .seconds(10.0),
                       tolerance: 2.0,
                       on: environment.mainQueue,
                       options: nil
                )
            .subscribe(on: DispatchQueue.global())
            .receive(on: environment.mainQueue)
            .map(AppAction.onUpdate)
            .eraseToEffect()
        case .run:
                                                              
            return .fireAndForget {
                
                if environment.userDefaults.string(forKey: "style") == "dark" {
                    UIApplication.shared.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .dark
                    }
                }
                
                if environment.userDefaults.string(forKey: "style") == "light" {
                    UIApplication.shared.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .light
                    }
                }
                
            }
        case .onUpdate:
            return .merge(
                Effect(value: .day(.onChange)),
                Effect(value: .year(.onChange)),
                Effect(value: .life(.onChange)),
                Effect(value: .union(.onChange)),
                Effect(value: .yourDay(.onChange)),
                Effect(value: .tasks(.onChange))
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
        case .lifeWidgetTapped:
            return .concatenate(
                Effect(value: .settingButtonTapped),
                Effect(value: .settings(.sectionTapped(.showSettings)))                
            )
        case .myDayWidgetTapped:
            return .concatenate(
                Effect(value: .settingButtonTapped),
                Effect(value: .settings(.sectionTapped(.showSettings)))
            )
        case .notificationResponse:
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
        environment: \.tasks
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
            taskClient: self.taskClient,
            notificationClient: self.notificationClient,
            mainQueue: self.mainQueue
        )
    }
}

extension AppEnvironment {
    var life: LifeEnvironment {
        LifeEnvironment(
            calendar: calendar,
            date: date,
            userDefaults: userDefaults,
            lifeProgress: timeClient.lifeProgress
        )
    }
}

import Core
import Combine
//Notification Reducer
extension Reducer where
    State == AppState,
    Action == AppAction,
    Environment == AppEnvironment {
    var notificationSettingReducer: Self {
        Self { state, action, environment in
            let effects = self(&state, action, environment)
            switch action {
            case let .settings(.notifications(notificationsAction)):
                switch notificationsAction {
                case let .didAuthorized(enabled):
                    return .fireAndForget {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        enabled
                            ? UIApplication.shared.registerForRemoteNotifications()
                            : UIApplication.shared.unregisterForRemoteNotifications()
                    }
                case let .didAuthorizedEnd(enabled):
                    return enabled
                    ? .concatenate(
                        state.tasksState
                            .tasks
                            .filter { $0.status != .completed }
                            .map {
                        environment.notificationClient.send(
                            .init(
                                notification: $0.task.notification,
                                date: $0.task.endDate
                            )).flatMap { _ in
                                Empty(completeImmediately: true)
                                    .eraseToAnyPublisher()
                            }.catch { _ in
                                Empty(completeImmediately: true)
                                    .eraseToAnyPublisher()
                            }.eraseToEffect()
                    })
                    : environment
                        .notificationClient
                        .removeRequests(state.tasksState.tasks.map(\.id.uuidString))
                        .eraseToEffect()
                        .fireAndForget()
                    
                case let .didAuthorizedCustom(enabled):
                    let goal = state.settingState!.notifications.reachingPoint
                    let value = percentFormatter().string(from: NSNumber(value: goal)) ?? ""
                    
                    return enabled
                    ? .concatenate(
                        state.tasksState
                            .tasks
                            .filter { $0.status != .completed }
                            .map {
                        environment.notificationClient.send(
                            .init(
                                notification: $0.task.customNotification(value),
                                date: $0.task.progress(goal)
                            )).catchToEffect()
                            .map(AppAction.notificationResponse)
                    })
                    : environment
                        .notificationClient
                        .removeRequests(state.tasksState.tasks.map { $0.id.uuidString + "custom" })
                        .eraseToEffect()
                        .fireAndForget()
                default:
                    return .none
                }
            default:
                return effects
            }
        }
    }
}

import TaskClient
extension ProgressTask {
    var notification: LocalNotification {
        LocalNotification(
            identifier: id.uuidString,
            title: title,
            subtitle: "100%",
            message: "task you started was ended"
        )
    }
}

extension ProgressTask {
    var customNotification: (String) -> LocalNotification {
        return {
            LocalNotification(
                identifier: id.uuidString + "custom",
                title: title,
                subtitle: $0,
                message: "task you started reach " + $0
            )
        }
    }
}

