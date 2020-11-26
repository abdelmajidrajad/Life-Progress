import Foundation
public protocol KeyValueStoreType: class {
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
        
    func bool(forKey defaultName: String) -> Bool
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func integer(forKey defaultName: String) -> Int
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    
    var birthDate: Date? { get set }
    var dayStart: Date? { get set }
    var dayEnd: Date? { get set }
    var life: Int { get set }
    var notificationsEnabled: Bool { get set }
    var endNotificationsEnabled: Bool { get set }
    var customNotificationsEnabled: Bool { get set }
    var taskNotificationPercent: Float? { get set }
    var hasSeenOnBoarding: Bool { get set  }
    
    func synchronize() -> Bool
}

extension KeyValueStoreType {
    public var birthDate: Date? {
      get {
        return self.object(forKey: AppKeys.birthDate.rawValue) as? Date
      }
      set {
        self.set(newValue, forKey: AppKeys.birthDate.rawValue)
      }
    }
    
    public var dayStart: Date? {
      get {
        return self.object(forKey: AppKeys.dayStart.rawValue) as? Date
      }
      set {
        self.set(newValue, forKey: AppKeys.dayStart.rawValue)
      }
    }
    
    public var dayEnd: Date? {
      get {
        return self.object(forKey: AppKeys.dayEnd.rawValue) as? Date
      }
      set {
        self.set(newValue, forKey: AppKeys.dayStart.rawValue)
      }
    }
    
    public var life: Int {
      get {
        return self.integer(forKey: AppKeys.life.rawValue)
      }
      set {
        self.set(newValue, forKey: AppKeys.life.rawValue)
      }
    }
    
    
    public var notificationsEnabled: Bool {
        get {
            return self.bool(forKey: AppKeys.notificationsEnabled.rawValue)
        }
        set {
            self.set(newValue, forKey: AppKeys.notificationsEnabled.rawValue)
        }
    }
    
    public var hasSeenOnBoarding: Bool {
        get {
            return self.bool(forKey: AppKeys.hasSeenOnBoarding.rawValue)
        }
        set {
            self.set(newValue, forKey: AppKeys.hasSeenOnBoarding.rawValue)
        }
    }
    
    
    public var endNotificationsEnabled: Bool {
        get {
            return self.bool(forKey: AppKeys.endNotificationsEnabled.rawValue)
        }
        set {
            self.set(newValue, forKey: AppKeys.endNotificationsEnabled.rawValue)
        }
    }
    
    public var customNotificationsEnabled: Bool {
        get {
            return self.bool(forKey: AppKeys.customNotificationsEnabled.rawValue)
        }
        set {
            self.set(newValue, forKey: AppKeys.customNotificationsEnabled.rawValue)
        }
    }
    
    public var taskNotificationPercent: Float? {
        get {
            return self.object(forKey: AppKeys.customNotificationsEnabled.rawValue) as? Float
        }
        set {
            self.set(newValue, forKey: AppKeys.customNotificationsEnabled.rawValue)
        }
    }
    
}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
    public func set(_ value: Int, forKey defaultName: String) {
        self.set(Int64(value), forKey: defaultName)
    }
    
    public func integer(forKey defaultName: String) -> Int {
        Int(longLong(forKey: defaultName))
    }
}

extension UserDefaults: KeyValueStoreType {}

public class TestUserDefault: KeyValueStoreType {
    public init() {}
    public func set(_ value: Bool, forKey defaultName: String) {}
    public func set(_ value: Int, forKey defaultName: String) {}
    public func set(_ value: Any?, forKey defaultName: String) {}
    public func bool(forKey defaultName: String) -> Bool { return false }
    public func dictionary(forKey defaultName: String) -> [String : Any]? { return nil }
    public func integer(forKey defaultName: String) -> Int { return .zero }
    public func object(forKey defaultName: String) -> Any? { return nil }
    public func string(forKey defaultName: String) -> String? { return nil }
    public func synchronize() -> Bool { return false }
}

//App Keys
public enum AppKeys: String {
    case birthDate = "com.lifeProgress.KeyValueStoreType.birthDate"
    case hasSeenOnBoarding = "com.lifeProgress.KeyValueStoreType.hasSeenOnBoarding"
    case life = "com.lifeProgress.KeyValueStoreType.life"
    case appStyle = "com.lifeProgress.KeyValueStoreType.appStyle"
    case dayStart = "com.lifeProgress.KeyValueStoreType.dayStart"
    case dayEnd = "com.lifeProgress.KeyValueStoreType.dayEnd"
    case notificationsEnabled = "come.lifeProgress.notificationsEnabled"
    case endNotificationsEnabled = "come.lifeProgress.endNotificationsEnabled"
    case customNotificationsEnabled = "come.lifeProgress.customNotificationsEnabled"    
}

