public protocol KeyValueStoreType: class {
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
        
    func bool(forKey defaultName: String) -> Bool
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func integer(forKey defaultName: String) -> Int
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    
    func synchronize() -> Bool
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
