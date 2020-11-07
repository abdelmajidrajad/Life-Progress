import UIKit
import UserNotifications
import Combine

public class LocalNotification: NSObject {
    
    public enum Failure: LocalizedError, Equatable {
        case weakness
        case custom(String)
    }
    
    public enum Response: Equatable {
        case requestId(String)
    }
    
    let identifier: String = UUID().uuidString
    let title: String
    let subtitle: String
    let message: String
    let badge: Int?
    
    public init(title: String, subtitle: String, message: String, badge: Int? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.message = message
        self.badge = badge
    }
    
    public func send() -> AnyPublisher<Response, Failure> {
        send(on: .init(timeIntervalSinceNow: 1))
    }
    
    public func send(on date: Date) -> AnyPublisher<Response, Failure>  {
        Deferred {
            Future<Response, Failure> { [weak self] promise in
                guard let self = self else {
                    promise(.failure(.weakness))
                    return
                }
                let content = UNMutableNotificationContent()
                content.title = self.title
                content.subtitle = self.subtitle
                content.body = self.message
                content.badge = self.badge == nil ? nil : NSNumber(value: self.badge!)
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: date - Date(),
                    repeats: false
                )
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger
                )
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        promise(.failure(.custom(error.localizedDescription)))
                    } else {
                        promise(.success(.requestId(request.identifier)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
}

