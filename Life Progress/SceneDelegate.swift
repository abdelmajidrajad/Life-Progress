import UIKit
import SwiftUI
import TimeClientLive
import TaskClientLive
import ComposableArchitecture
//import Tasks
import Settings

import Components

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let contentView = ContentView(
            store: Store(
                initialState: AppState(),
                reducer: appReducer,
                environment:  .live
            )
        )

        //let contentView = FullProgressView().frame(width: 170, height: 170, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
//        let contentView =
//            NavigationView {
//                SettingsView(store: Store(
//                    initialState: SettingState(),
//                    reducer: settingReducer,
//                    environment:
//                        SettingsEnvironment(
//                            userDefaults: UserDefaults.standard
//                        )
//                ))
//            }
        
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
        LPPersistentContainer.saveContext()
    }
    
    
}
