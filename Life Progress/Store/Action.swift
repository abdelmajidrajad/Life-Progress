import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import TaskClient
import Components
import CoreData
import Tasks

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
