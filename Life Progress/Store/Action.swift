import SwiftUI
import Core
import ComposableArchitecture
import Components
import CoreData
import Tasks
import Settings

enum AppAction: Equatable {
    case run
    case onStart
    case onUpdate(DispatchQueue.SchedulerTimeType)
    case settingButtonTapped
    case shareButtonTapped
    case viewDismissed
    case lifeWidgetTapped
    case myDayWidgetTapped
    case onBoardingDismissed
    case year(YearAction)
    case day(DayAction)
    case union(SwitchAction)
    case tasks(TasksAction)
    case life(LifeProgressAction)
    case yourDay(YourDayProgressAction)
    case settings(SettingAction)
    case share(ShareAction)
    case features(AppFeatureAction)
    case notificationResponse(Result<NotificationClient.Response, NotificationClient.Failure>)
}
