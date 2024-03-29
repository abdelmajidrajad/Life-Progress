import UIKit
import SwiftUI
import TimeClientLive
import TaskClientLive
import ComposableArchitecture
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
