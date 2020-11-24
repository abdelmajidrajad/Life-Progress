import UIKit
import UserNotifications
import Combine

public class LocalNotification: NSObject {
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
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
}


import UserNotifications
public struct NotificationClient {
    
    public enum Response: Equatable {
        case response(UNNotificationRequest)
    }
    
    public struct Request: Equatable {
        let notification: LocalNotification
        let date: Date
    }
    
    public enum Failure: LocalizedError {
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
    
    public init(
        requestAuthorization: AnyPublisher<AuthorizationStatus, Failure>,
        authorizationStatus: AnyPublisher<AuthorizationStatus, Failure>,
        send: @escaping (Request) -> AnyPublisher<Response, Failure>
    ) {
        self.requestAuthorization = requestAuthorization
        self.authorizationStatus = authorizationStatus
        self.send = send
    }
}

extension NotificationClient {
    public var live: NotificationClient {
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
                        let trigger = UNTimeIntervalNotificationTrigger(
                            timeInterval: request.date - Date(),
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
                                promise(.success(.response(request)))
                            }
                        }
                    }
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
                Just(.response(UNNotificationRequest(identifier: "", content: .init(), trigger: nil)))
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }
        )
    }
}
 
