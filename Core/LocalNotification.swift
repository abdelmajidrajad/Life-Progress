import UIKit
import UserNotifications
import Combine

public class LocalNotification: NSObject {
    
    public enum Failure: LocalizedError, Equatable {
        case weakness
        case custom(String)
    }
    
    public enum Response: Equatable {
        case request(UNNotificationRequest)
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
                        promise(.success(.request(request)))
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


import UserNotifications

func dismiss() {
    UNUserNotificationCenter
        .current()
        .requestAuthorization(options: [.alert, .badge, .sound]) { (bool, error) in
    }
}

import Combine
public struct NotificationClient {
    
    public enum Response: Equatable {
        case request(UNNotificationRequest)
    }
    
    public enum Failure: LocalizedError {
        case notAuthorized
        case custom(String)
    }
    
    public enum AuthorizationStatus: Equatable {
        case allow
        case denied
    }
    
    public let authorizationStatus: AnyPublisher<AuthorizationStatus, Failure>
    public let send: (Date) -> AnyPublisher<Response, Failure>
    public let requestAuthorization: () -> Void
    
    public init(
        requestAuthorization: @escaping () -> Void,
        authorizationStatus: AnyPublisher<AuthorizationStatus, Failure>,
        send: @escaping (Date) -> AnyPublisher<Response, Failure>
    ) {
        self.requestAuthorization = requestAuthorization
        self.authorizationStatus = authorizationStatus
        self.send = send
    }
}

extension NotificationClient {
    public static var empty: Self {
        Self(
            requestAuthorization: {},
            authorizationStatus: Just(.allow)
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher(),
            send: { _ in
                Just(.request(UNNotificationRequest(identifier: "", content: .init(), trigger: nil)))
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }
        )
    }
}
 
