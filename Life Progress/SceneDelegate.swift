import UIKit
import SwiftUI
import TimeClientLive
import TaskClientLive
import ComposableArchitecture
import Tasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
//        let contentView = ContentView(
//            store: Store(
//                initialState: AppState(),
//                reducer: appReducer,
//                environment:  AppEnvironment(
//                    uuid: UUID.init,
//                    date: Date.init,
//                    calendar: .current,
//                    timeClient: .live,
//                    context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//                )
//            )
//        )
        
        let contentView = CreateTaskView(store: Store(
                        initialState: CreateTaskState(),
                        reducer: createTaskReducer,
            environment: CreateTaskEnvironment(
                date: Date.init,
                calendar: .current,
                timeClient: .live,
                taskClient: .live,
                managedContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            )
        ))
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
        //Task(entity: <#T##NSEntityDescription#>, insertInto: <#T##NSManagedObjectContext?#>)
        
    }
    
    
}





//extension UIColor {
//    public var data: Data {
//        rgb.withUnsafeBufferPointer { p in
//            Data(
//                bytes: UnsafePointer<UInt8>(p.baseAddress!),
//                count: 1
//            )
//        }
//    }
//}
//
//extension Data {
//    public var moodColors: UIColor? {
//        guard count > 0 && count % 3 == 0 else { return nil }
//        var rgbValues = Array(repeating: UInt8(), count: count)
//        rgbValues.withUnsafeMutableBufferPointer { buffer in
//            let voidPointer = UnsafeMutableRawPointer(buffer.baseAddress)
//            let _ = withUnsafeBytes { bytes -> Bool in
//                memcpy(voidPointer, bytes.baseAddress, count)
//                return true
//            }
//        }
//        
//        let rgbSlices = rgbValues.chunked(into: 3)
//        return rgbSlices.map { slice in
//            guard let color = UIColor(rawData: slice) else {
//                fatalError("cannot fail since we know tuple is of length 3")
//            }
//            return color
//        }.first
//    }
//}
//
//extension Array {
//    func chunked(into size: Int) -> [[Element]] {
//        return stride(from: 0, to: count, by: size).map {
//            Array(self[$0 ..< Swift.min($0 + size, count)])
//        }
//    }
//}
//
//extension UIColor {
//    fileprivate convenience init?(rawData: [UInt8]) {
//        if rawData.count != 3 { return nil }
//        let red = CGFloat(rawData[0]) / 255
//        let green = CGFloat(rawData[1]) / 255
//        let blue = CGFloat(rawData[2]) / 255
//        self.init(red: red, green: green, blue: blue, alpha: 1)
//    }
//}
//
//extension UIColor {
//    var rgb: [UInt8] {
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        getRed(&red, green: &green, blue: &blue, alpha: nil)
//        return [UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255)]
//    }
//}
//
//
//extension Task {
//    static func registerValueTransformers() {
//        _ = self.__registerOnce
//    }
//    
//    
//    
//    fileprivate static let __registerOnce: () = {
//        ValueTransformer.setValueTransformer(
//            .init()
//            , forName: .init(rawValue: "ColorTransformer")
//        )
////        (
////            withName: "ColorTransformer",
////                transform:
////                { (colors: NSArray?) -> NSData? in
////                    guard let colors = colors as? [UIColor] else { return nil }
////                    return colors.moodData as NSData
////                }, reverseTransform: { (data: NSData?) -> NSArray? in
////                    return (data as? Data)?.moodColors.map { $0 as NSArray } })
////        }()
//    
//    }()
