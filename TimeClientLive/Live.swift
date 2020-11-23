import TimeClient
import Combine
import Foundation

extension TimeClient {
    public static let live: TimeClient =
        TimeClient(
            yearProgress: { request in
                Deferred {
                    Future<TimeResponse, Never> { promise in
                        
                        let year =  request.calendar
                            .dateComponents([.year], from: request.date).year!
                        
                        let startOfYear = request.calendar.date(
                            from: DateComponents(year: year, month: 1, day: 1)
                        )!
                        
                        let endOfYear = request.calendar.date(
                            from: DateComponents(
                                year: year,
                                month: 12,
                                day: 31)
                        )!
                        
                        let yearHours = request.calendar
                            .dateComponents([.hour],
                                            from: startOfYear,
                                            to: endOfYear).hour!
                        
                        let remainingHours = request.calendar.dateComponents(
                            [.hour],
                            from: request.date,
                            to: endOfYear).hour!
                        
                        let components = request.calendar.dateComponents(
                            request.resultType.components,
                            from: request.date,
                            to: endOfYear
                        )
                        
                        switch request.resultType {
                        case .short:
                            promise(.success(
                                TimeResponse(
                                    progress: 1 - Double(remainingHours) / Double(yearHours),
                                    result: TimeResult(
                                        day: components.day!,
                                        hour: components.hour!,
                                        minute: components.minute!
                                    ))
                            ))
                        case .long:
                            promise(.success(
                                TimeResponse(
                                    progress: 1 - Double(remainingHours) / Double(yearHours),
                                    result: TimeResult(
                                        year: components.year!,
                                        month: components.month!,
                                        day: components.day!,
                                        hour: components.hour!,
                                        minute: components.minute!
                                    ))
                            ))
                        }
                    }
                }.eraseToAnyPublisher()
            },
            todayProgress: { request in
                Deferred {
                    Future { promise in
                        
                        let components = request.calendar
                            .dateComponents(
                                [.hour, .minute],
                                from: request.date,
                                to: endOfDay(request.date, request.calendar)
                            )
                        
                        let endOfDay = request.calendar
                            .startOfDay(for: request.date.advanced(by: 3600 * 24)
                        )
                        
                        let remainingMinutes = request
                            .calendar
                            .dateComponents([.minute],
                                            from: request.date,
                                            to: endOfDay).minute!
                                                    
                        promise(.success(
                            TimeResponse(
                                progress: 1 - Double(remainingMinutes) / Double(24 * 60),
                                result: TimeResult(
                                    hour: components.hour!,
                                    minute: components.minute!
                                )
                            )
                        ))
                        
                    }
                }.eraseToAnyPublisher()
            }, weekProgress: { request in
                Deferred {
                    Future { promise in
                        let weekOfYear = request.calendar
                            .dateComponents(
                                [.weekOfYear],
                                from: request.date)
                            .weekOfYear!
                        
                        let weekday =
                            request.calendar
                            .dateComponents(
                                [.weekday],
                                from: request.date)
                            .weekday!
                        
                        let weeksCount = request.calendar.range(
                            of: .weekOfYear,
                            in: .yearForWeekOfYear,
                            for: request.date
                        )?.count ?? 1
                                                                        
                        let passedTime = Double(weekOfYear) / Double(weeksCount)
                        
                        promise(.success(
                            WeekResponse(
                                currentWeek: weekOfYear,
                                remainingWeeks: weeksCount - weekday,
                                progress: passedTime
                            )
                        ))
                    }
                }.eraseToAnyPublisher()
                
            }, taskProgress: { request in
                .future { promise in
                    
                    var components: DateComponents!
                    
                    if request.currentDate < request.startAt {
                        components = request.calendar.dateComponents(
                            [.year, .month, .day, .hour, .minute],
                            from: request.startAt,
                            to: request.endAt
                        )
                    }
                    
                    if request.currentDate > request.startAt && request.currentDate < request.endAt {
                        components = request.calendar.dateComponents(
                            [.year, .month, .day, .hour, .minute],
                            from: request.currentDate,
                            to: request.endAt
                        )
                    }
                    
                    if request.currentDate > request.endAt {
                        components = DateComponents()
                    }
                                                            
                    
                    let taskMinutes = request.calendar
                        .dateComponents([.minute],
                                        from: request.startAt,
                                        to: request.endAt).minute!
                    
                    let passedMinutes = request.calendar
                        .dateComponents([.minute],
                                        from: request.startAt,
                                        to: request.currentDate).minute!
                                                                                
                    promise(.success(
                        TimeResponse(
                            progress: min(Double(max(passedMinutes, 0)) / Double(taskMinutes), 1),
                            result: TimeResult(
                                year: components.year ?? .zero,
                                month: components.month ?? .zero,
                                day: components.day ?? .zero,
                                hour: components.hour ?? .zero,
                                minute: components.minute ?? .zero)
                        )
                    ))
                }
            }, yourDayProgress: { request in
                .future { promise in
                    guard let startDate = request.calendar.date(
                            bySettingHour: request.start.hour,
                            minute: request.start.minute,
                            second: .zero,
                            of: request.date),
                          let endDate = request.calendar.date(
                            bySettingHour: request.end.hour,
                            minute: request.end.minute,
                            second: .zero,
                            of: request.date)
                    else {
                        promise(
                            .success(TimeResponse(
                                        progress: .zero,
                                        result: .zero)
                            ))
                        return
                    }
                                       
                    let passedMinutes = request.calendar
                        .dateComponents(
                            [.minute],
                            from: startDate,
                            to: request.date
                        ).minute!
                    
                    let minutes = request.calendar
                        .dateComponents(
                            [.minute],
                            from: startDate,
                            to: endDate
                        ).minute!
                    
                    
                    let passedTime = request.calendar
                        .dateComponents(
                            [.minute, .hour],
                            from: startDate,
                            to: request.date
                        )
                    
                    let time = request.calendar
                        .dateComponents(
                            [.minute, .hour],
                            from: startDate,
                            to: endDate
                        )
                    
                    let component = request.calendar.dateComponents(
                        [.minute, .hour], from: passedTime, to: time)
                    
                    promise(
                        .success(
                            TimeResponse(
                                progress: max(.zero, min(1.0, Double(passedMinutes) / Double(minutes))),
                                result: TimeResult(
                                    hour: max(0, component.hour!),
                                    minute: max(0, component.minute!)
                                )
                            )
                        )
                    )
                }
            }, lifeProgress: { request in
                .future { promise in
                    promise(
                        .success(
                            TimeResponse(
                                progress: min(1.0, Double(request.age) / Double(request.expectedLife)),
                                result: TimeResult(
                                    year: request.expectedLife - request.age
                                )
                            )
                        )
                    )
                }
            }
        )    
}


extension AnyPublisher {
    public static func future(
        _ attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void
    ) -> AnyPublisher {
        Deferred {
            Future { callback in
                attemptToFulfill { result in callback(result) }
            }
        }.eraseToAnyPublisher()
    }
}

let yourDayProgress:
    (YourDayRequest) -> AnyPublisher<TimeResponse, Never> = { request in
        
        guard let startDate = request.calendar.date(
                bySettingHour: request.start.hour,
                minute: request.start.minute,
                second: .zero,
                of: request.date),
              let endDate = request.calendar.date(
                bySettingHour: request.end.hour,
                minute: request.end.minute,
                second: .zero,
                of: request.date),
              let passedHours = request.calendar
                .dateComponents([.hour],
                                from: startDate,
                                to: request.date).hour,
              let hours = request.calendar
                .dateComponents([.hour],
                                from: startDate,
                                to: endDate).hour
        else {
            return .none
        }
                                        
        return .none
    }
