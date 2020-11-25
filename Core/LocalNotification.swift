import UIKit
import UserNotifications
import Combine

public class LocalNotification: NSObject {
    let identifier: String
    let title: String
    let subtitle: String
    let message: String
    let badge: Int?
    public init(
        identifier: String,
        title: String,
        subtitle: String,
        message: String,
        badge: Int? = nil
    ) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.message = message
        self.badge = badge
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
}

import UserNotifications
public struct NotificationClient {
    
    public enum Response: Equatable {
        case success
    }
    
    public struct Request: Equatable {
        let notification: LocalNotification
        let date: Date
        public init(
            notification: LocalNotification,
            date: Date
        ) {
            self.notification = notification
            self.date = date
        }
    }
    
    public enum Failure: LocalizedError, Equatable {
        case notAuthorized
        case custom(String)
    }
    
    public enum AuthorizationStatus: Equatable {
        case allow
        case denied
        case notDetermined
    }
    
    public let authorizationStatus: AnyPublisher<AuthorizationStatus, Failure>
    public let send: (Request) -> AnyPublisher<Response, Failure>
    public let requestAuthorization: AnyPublisher<AuthorizationStatus, Failure>
    public let removeRequests: ([String]) -> AnyPublisher<Never, Never>
    
    public init(
        requestAuthorization: AnyPublisher<AuthorizationStatus, Failure>,
        authorizationStatus: AnyPublisher<AuthorizationStatus, Failure>,
        send: @escaping (Request) -> AnyPublisher<Response, Failure>,
        removeRequests: @escaping ([String]) -> AnyPublisher<Never, Never>
    ) {
        self.requestAuthorization = requestAuthorization
        self.authorizationStatus = authorizationStatus
        self.send = send
        self.removeRequests = removeRequests
    }
}

extension NotificationClient {
    public static var live: NotificationClient {
        NotificationClient(
            requestAuthorization:
                Deferred {
                    Future<AuthorizationStatus, Failure> { promise in
                        UNUserNotificationCenter.current().requestAuthorization(
                            options: [.alert, .sound]) { (granted, error) in
                            if let _ = error {
                                promise(.failure(.notAuthorized))
                            }
                            promise(.success(granted ? .allow: .denied))
                        }
                        
                    }
                }.eraseToAnyPublisher()
            ,
            authorizationStatus: Deferred {
                Future<AuthorizationStatus, Failure> { promise in
                    UNUserNotificationCenter
                        .current()
                        .getNotificationSettings(completionHandler: { (settings) in
                            switch settings.authorizationStatus {
                            case .notDetermined:
                                promise(.success(.notDetermined))
                            case .denied:
                                promise(.success(.denied))
                            case .authorized, .provisional, .ephemeral:
                                promise(.success(.allow))
                            @unknown default:
                                promise(.success(.notDetermined))
                            }
                    })
                }
            }.eraseToAnyPublisher(),
            send: { request in
                Deferred {
                    Future<Response, Failure> {  promise in
                        let content = UNMutableNotificationContent()
                        content.title = request.notification.title
                        content.subtitle = request.notification.subtitle
                        content.body = request.notification.message
                        content.badge = request.notification.badge == nil ? nil : NSNumber(value: request.notification.badge!)
                        
                        let components = Calendar.current.dateComponents(
                            [.hour, .minute, .day, .month],
                            from: request.date)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                                                
                        let request = UNNotificationRequest(
                            identifier: request.notification.identifier,
                            content: content,
                            trigger: trigger
                        )
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                promise(.failure(.custom(error.localizedDescription)))
                            } else {
                                promise(.success(.success))
                            }
                        }
                    }
                }.eraseToAnyPublisher()
                
            }, removeRequests: { identifiers in
                Deferred { () -> Empty<Never, Never> in
                    UNUserNotificationCenter
                        .current()
                        .removePendingNotificationRequests(withIdentifiers: identifiers)
                    return Empty(completeImmediately: true)
                }.eraseToAnyPublisher()
            }
        )
    }
}

extension NotificationClient {
    public static var empty: Self {
        Self(
            requestAuthorization: Just(AuthorizationStatus.allow)
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher(),
            authorizationStatus: Just(AuthorizationStatus.allow)
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher(),
            send: { _ in
                Just(.success)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }, removeRequests: { _ in
                Empty(completeImmediately: true)
                    .eraseToAnyPublisher()
            }
        )
    }
}
 
