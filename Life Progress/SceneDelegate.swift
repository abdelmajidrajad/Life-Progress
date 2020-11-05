import UIKit
import SwiftUI
import TimeClientLive
import TaskClientLive
import ComposableArchitecture
import Tasks
import Settings

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
//        let contentView = ContentView(
//            store: Store(
//                initialState: AppState(),
//                reducer: appReducer.debug(),
//                environment:  AppEnvironment(
//                    uuid: UUID.init,
//                    date: Date.init,
//                    calendar: .current,
//                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
//                    timeClient: .live,
//                    taskClient: .live,
//                    context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
//                    userDefaults: UserDefaults.standard
//                )
//            )
//        )
        
        
        let contentView = SettingsView()
        
//
//        let contentView = CreateTaskView(store: Store(
//                        initialState: CreateTaskState(),
//                        reducer: createTaskReducer,
//            environment: CreateTaskEnvironment(
//                date: Date.init,
//                calendar: .current,
//                timeClient: .live,
//                taskClient: .live,
//                managedContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//            )
//        ))
        
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
        // Save changes in the application's managed object context when the
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}
