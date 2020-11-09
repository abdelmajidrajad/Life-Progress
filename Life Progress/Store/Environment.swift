import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import TaskClient
import CoreData


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

import Components
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
