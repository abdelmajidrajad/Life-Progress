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
