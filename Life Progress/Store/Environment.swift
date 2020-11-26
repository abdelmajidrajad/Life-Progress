import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import TaskClient
import CoreData
import Settings

struct AppEnvironment {
    let uuid: () -> UUID
    let date: () -> Date
    let calendar: Calendar
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let timeClient: TimeClient
    let taskClient: TaskClient
    let context: NSManagedObjectContext
    let userDefaults: KeyValueStoreType
    let ubiquitousStore: KeyValueStoreType
    let shareClient: ShareClient
    let notificationClient: NotificationClient
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
            ubiquitousStore: ubiquitousStore,
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

extension AppEnvironment {
    var settings: SettingsEnvironment {
        SettingsEnvironment(
            date: self.date,
            calendar: self.calendar,
            userDefaults: self.userDefaults,
            ubiquitousStore: ubiquitousStore,
            mainQueue: self.mainQueue
        )
    }
}

import TimeClientLive
import TaskClientLive
extension AppEnvironment {
    public static var live: AppEnvironment {
        AppEnvironment(
            uuid: UUID.init,
            date: Date.init,
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: .live,
            taskClient: .live,
            context: LPPersistentContainer.context,
            userDefaults: UserDefaults(suiteName: "group.progress.app") ?? .standard,
            ubiquitousStore: NSUbiquitousKeyValueStore.default,
            shareClient: .live,
            notificationClient: .live
        )
    }
}

extension AppEnvironment {
    public static func live(future date: @autoclosure @escaping () -> Date) -> AppEnvironment {
        AppEnvironment(
            uuid: UUID.init,
            date: date,
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: .live,
            taskClient: .live,
            context: LPPersistentContainer.context,
            userDefaults: 
                UserDefaults(suiteName: "group.progress.app") ?? .standard,
            ubiquitousStore: NSUbiquitousKeyValueStore.default,
            shareClient: .mock,
            notificationClient: .empty
        )
    }
}




