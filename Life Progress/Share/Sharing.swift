import ComposableArchitecture
import UIKit
import SwiftUI
    
public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

var RootController: UIViewController?  {
    UIApplication.shared.windows.last?.visibleViewController
}
        
func shareImage(_ image: UIImage?) -> Void {
    //let appURL = URL(string: "https://apps.apple.com/app/id1527416109")!
    
    let activityVC = UIActivityViewController(
        activityItems: [image ?? UIImage(named: "progressIcon")!],
        applicationActivities: nil
    )
    activityVC.popoverPresentationController?.sourceView =
        RootController?.view
            
    activityVC.popoverPresentationController?.sourceRect =
        CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
    RootController?.present(activityVC, animated: true)
}

func getSnapShot<V: View>(from view: V) -> Effect<UIImage, Never> {
    Effect.future { (promise) in
        VStack {
            Text("Make Progress")
                .bold()
                .padding()
            view
                .frame(width: .py_grid(55))
            ApplicationView()
        }.frame(width: .py_grid(80), height: .py_grid(80))
        .padding(.py_grid(1))
        .snapShot(
            origin: .zero,
            size: CGSize(width: .py_grid(100), height: .py_grid(100))) { image in
            promise(.success(image))
        }
    }
}

public let shareReducer =
Reducer<ShareState, ShareAction, ShareEnvironment> { state, action, environment in
    switch action {
    case let .activityButtonTapped(activity: activity):
        switch activity {
        case .facebook:
            return .none
        case .whatsapp:
            return .none
        case .snapchat:
            return .none
        case .instagram:
            return .none
        }
    case let .didScroll(to: index):
        state.currentIndex = index
        return .none
    case .moreButtonTapped:
        return getSnapShot(from: state.views[state.currentIndex])
            .map(ShareAction.share)
    case let .share(image):
        return Effect.fireAndForget {
            shareImage(image)
        }.receive(on: DispatchQueue.main.eraseToAnyScheduler())
        .eraseToEffect()
    }
}


extension Reducer where
    State == AppState,
    Action == AppAction,
    Environment == AppEnvironment {
    func share() -> Self {
        Self { state, action, environment in
            let effects = self(&state, action, environment)
            let shareAction = extract(case: AppAction.share, from: action)
            if let shareAction = shareAction {
                return shareReducer.optional()
                    .run(&state.shareState, shareAction, ShareEnvironment())
                    .map(AppAction.share)
                    .eraseToEffect()
            } else {
                return effects
            }
        }
    }
}
