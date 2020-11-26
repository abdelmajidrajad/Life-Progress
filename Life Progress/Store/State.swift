import SwiftUI
import Core
import ComposableArchitecture
import Components
import Tasks
import Settings

struct AppState: Equatable {
    //var hasSeenOnBoarding: Bool = false
    var features: AppFeatureState?
    var yearState: YearState
    var dayState: DayState
    var switchState: SwitchState
    var tasksState: TasksState
    var yourDayState: YourDayProgressState
    var life: LifeProgressState
    var settingState: SettingState?
    var shareState: ShareState?
    public init(
        yearState: YearState = .init(style: .circle),
        dayState: DayState = .init(style: .circle),
        switchState: SwitchState = .init(),
        tasksState: TasksState = .init(),
        yourDayState: YourDayProgressState = .init(),
        life: LifeProgressState = LifeProgressState(),
        settingState: SettingState? = nil,
        shareState: ShareState? = nil,
        features: AppFeatureState? = nil//= 
    ) {
        self.features = features
        self.settingState = settingState
        self.yearState = yearState
        self.dayState = dayState
        self.switchState = switchState
        self.tasksState = tasksState
        self.yourDayState = yourDayState
        self.life = life
        self.shareState = shareState
    }
}


import TimeClient
import TaskClient
extension AppState {
    static var mock: AppState {
        AppState(
            yearState: YearState(
                year: 2020,
                result: TimeResult(month: 2, day: 12),
                style: .bar,
                percent: 0.3
            ),
            dayState: DayState(
                timeResult: TimeResult(hour: 11, minute: 10),
                style: .circle,
                percent: 0.67
            ),
            switchState: SwitchState(
                timeResult: TimeResult(month: 8, day: 2),
                dayResult: TimeResult(hour: 10),
                style: .circle,
                yearPercent: 0.5,
                todayPercent: 0.8,
                year: 2020
            ),
            tasksState: .completed,
            yourDayState: YourDayProgressState(
                timeResult: TimeResult(hour: 9, minute: 19),
                style: .bar,
                percent: 0.8
            ),
            life: LifeProgressState(
                timeResult: TimeResult(year: 30),
                style: .bar,
                percent: 0.3
            ),
            settingState: nil,
            shareState: nil
        )
    }
}

extension ProgressTask {
    public static var prepareDinner: Self {
        ProgressTask(
            id: UUID(),
            title: "Prepare Dinner",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600 * 24 * 2),
            creationDate: Date(),
            color: .systemBlue,
            style: .bar
        )
    }
    public static var goToBank: Self {
        ProgressTask(
            id: UUID(),
            title: "Go to Bank",
            startDate: Date(),
            endDate: Date(),
            creationDate: Date(),
            color: .systemGreen,
            style: .bar
        )
    }
    public static var visitMyFather: Self {
        ProgressTask(
            id: UUID(),
            title: "Visit My Father",
            startDate: Date(),
            endDate: Date(),
            creationDate: Date(),
            color: .systemPurple,
            style: .bar
        )
    }
    public static var cleanHouse: Self {
        ProgressTask(
            id: UUID(),
            title: "Clean House",
            startDate: Date(),
            endDate: Date(),
            creationDate: Date(),
            color: .systemPink,
            style: .bar
        )
    }
}


extension TasksState {
    static var active: TasksState {
        TasksState(
            tasks: [
                TaskState(
                    task: .prepareDinner,
                    progress: 0.6,
                    result: TimeResult(hour: 1, minute: 34),
                    status: .completed
                ),
                TaskState(
                    task: .goToBank,
                    progress: 0.2,
                    result: TimeResult(day: 1, hour: 2, minute: 10),
                    status: .active
                ),
                TaskState(
                    task: .visitMyFather,
                    progress: 0.82,
                    result: TimeResult(hour: 10, minute: 54),
                    status: .active
                ),
                TaskState(
                    task: .cleanHouse,
                    progress: 0.91,
                    result: TimeResult(minute: 34),
                    status: .active
                )
            ],
            createTask: nil,
            filter: .active
        )
    }
}

extension TasksState {
    static var completed: TasksState {
        TasksState(
            tasks: [
                TaskState(
                    task: .prepareDinner,
                    progress: 1.0,
                    result: .zero,
                    status: .completed
                ),
                TaskState(
                    task: .goToBank,
                    progress: 1.0,
                    result: .zero,
                    status: .completed
                ),
                TaskState(
                    task: .visitMyFather,
                    progress: 1.0,
                    result: .zero,
                    status: .completed
                ),
                TaskState(
                    task: .cleanHouse,
                    progress: 1.0,
                    result: .zero,
                    status: .completed
                )
            ],
            createTask: nil,
            filter: .completed
        )
    }
}
