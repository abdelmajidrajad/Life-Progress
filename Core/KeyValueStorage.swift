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


