import Foundation
import TimeClientLive
import TimeClient
import ComposableArchitecture
import Components

struct SharedEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let timeClient: TimeClient
    let userDefaults: UserDefaults
}

extension SharedEnvironment {
    static let shared: SharedEnvironment =
        SharedEnvironment(
            date: Date.init,
            calendar: Calendar.current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: .live,
            userDefaults: UserDefaults(suiteName: "group.progress.app") ?? .standard
        )
}

extension SharedEnvironment {   
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

extension SharedEnvironment {
    var year: YearEnvironment {
        YearEnvironment(
            calendar: calendar,
            date: date,
            yearProgress: timeClient.yearProgress
        )
    }
}

extension SharedEnvironment {
    var life: LifeEnvironment {
        LifeEnvironment(
            calendar: calendar,
            date: date,
            userDefaults: userDefaults,
            lifeProgress: timeClient.lifeProgress
        )
    }
}
