import Foundation
class TaskClientClass {}
extension Bundle {
    public static var taskClient: Bundle {
        Bundle(for: TaskClientClass.self)
    }
}
