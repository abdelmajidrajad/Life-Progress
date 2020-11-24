import UIKit
import SwiftUI
import TimeClientLive
import TaskClientLive
import ComposableArchitecture
import Components

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let store = Store(
            initialState: AppState(),
            reducer: appReducer.debugActions(),
            environment:  .live
        )
                
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView:
                                                                NavigationView {
                                                                    ContentView(store: store)
                                                                }
            )
            self.window = window
            window.makeKeyAndVisible()
        }
        
        ViewStore(store).send(.run)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {        
        LPPersistentContainer.saveContext()
    }
    
    
}
