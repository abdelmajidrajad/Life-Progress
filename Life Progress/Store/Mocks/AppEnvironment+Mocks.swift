import Combine
import TimeClient
import TaskClient
import Foundation

extension AppEnvironment {
    public static var empty: Self {
        Self(
            uuid: UUID.init,
            date: Date.init,
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: .empty,
            taskClient: .empty,
            context: .init(concurrencyType: .privateQueueConcurrencyType),
            userDefaults: UserDefaults(),
            ubiquitousStore: .init(),
            shareClient: .mock
        )
    }
}

extension AppEnvironment {
    static var midDay: Self {
        Self(
            uuid: UUID.init,
            date: { Date(timeIntervalSince1970: 3600 * 24 * 6) },
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: TimeClient(
                yearProgress: { _ in Just(TimeResponse(
                    progress: 0.38,
                    result: TimeResult(
                        hour: 13, minute: 12
                    )
                )).eraseToAnyPublisher()
                }, todayProgress: { _ in
                    Just(TimeResponse(
                    progress: 0.8,
                    result: TimeResult(
                        day: 19, hour: 13
                    )
                )).eraseToAnyPublisher()
                }, taskProgress: { _ in
                    Just(
                        TimeResponse(
                            progress: 0.76,
                            result: TimeResult(
                                //year: 2,
                                //month: 1,
                                day: 7,
                                hour: 12,
                                minute: 44
                            )
                        )
                    ).eraseToAnyPublisher()
                }, yourDayProgress: { _ in
                    Just(
                        TimeResponse(
                            progress: 0.76,
                            result: TimeResult(
                                //year: 2,
                                //month: 1,
                                //day: 7,
                                hour: 6,
                                minute: 44
                            )
                        )
                    ).eraseToAnyPublisher()
                }
                
            ),
            taskClient:
                TaskClient(tasks: { _ in
                    Just(TaskResponse.tasks([
                        .readBook, .writeBook, .writeBook2
                    ]))
                    .setFailureType(to: TaskFailure.self)
                    .eraseToAnyPublisher()
                }),
            context: .init(concurrencyType: .privateQueueConcurrencyType),
            userDefaults: UserDefaults(),
            ubiquitousStore: .init(),
            shareClient: .mock
        )
    }
}


