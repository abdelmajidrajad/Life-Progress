import Foundation

extension Bundle {
    class Component { }
    static var component: Bundle {
        return Bundle(for: Component.self)
    }
}
