import SwiftUI
import Core
import ComposableArchitecture
import Components
import Tasks
import Settings

struct AppState: Equatable {
    var yearState: YearState
    var dayState: DayState
    var switchState: SwitchState
    var tasksState: TasksState
    var yourDayState: YourDayProgressState
    var life: LifeProgressState
    var settingState: SettingState?
    public init(
        yearState: YearState = .init(style: .circle),
        dayState: DayState = .init(style: .circle),
        switchState: SwitchState = .init(),
        tasksState: TasksState = .init(),
        yourDayState: YourDayProgressState = .init(),
        life: LifeProgressState = LifeProgressState(),
        settingState: SettingState? = nil
    ) {
        self.settingState = settingState
        self.yearState = yearState
        self.dayState = dayState
        self.switchState = switchState
        self.tasksState = tasksState
        self.yourDayState = yourDayState
        self.life = life
    }
}
