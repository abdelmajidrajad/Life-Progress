import ComposableArchitecture
import UIKit
import SwiftUI
    
extension ShareClient {
    static var mock: Self {
        .init(
            share: { _ in Empty().eraseToAnyPublisher() },
            snapShot: { _ in Just(UIImage(named: "progressIcon")!)
                .eraseToAnyPublisher() }
        )
    }
}

struct RootController {
    let viewController: () -> UIViewController?
    func callAsFunction() -> UIViewController? {
        viewController()
    }
}


extension ShareClient {
    static var live: Self {
        Self(
            share: { items in
                                                
                let activityVC = UIActivityViewController(
                    activityItems: items,
                    applicationActivities: nil
                )
                activityVC.popoverPresentationController?.sourceView =
                    RootController.live()?.view
                
                activityVC.popoverPresentationController?.sourceRect =
                    CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
                RootController.live()?.present(activityVC, animated: true)
                
                return Empty(completeImmediately: true)
                    .eraseToAnyPublisher()
                
            },
            snapShot: { view in
                Future<UIImage, Never> { promise in
                    view
                    .snapShot(
                        origin: .zero,
                        size: CGSize(width: .py_grid(100), height: .py_grid(100))) { image in
                        promise(.success(image))
                    }
                }.eraseToAnyPublisher()
            }
        )
    }
}


import Combine
public struct ShareEnvironment {
    let shareClient: ShareClient
    let mainQueue: AnySchedulerOf<DispatchQueue>
}
        

/*
 
 */

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
        return environment.shareClient.snapShot(
            VStack {
                Text(ShareProgressData.allCases[state.currentIndex].rawValue)
                    .bold()
                    .padding()
                state.views[state.currentIndex]
                    .frame(width: .py_grid(55))
                ApplicationView()
            }.frame(width: .py_grid(80), height: .py_grid(80))
            .padding(.py_grid(1))
            .anyView()
        )
        .map(ShareAction.share)
        .eraseToEffect()
    case let .share(image):
        return environment.shareClient.share([image])
            .receive(on: DispatchQueue.main.eraseToAnyScheduler())
            .eraseToEffect()
            .fireAndForget()
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
                    .run(&state.shareState, shareAction, environment.share)
                    .map(AppAction.share)
                    .eraseToEffect()
            } else {
                return effects
            }
        }
    }
}

extension AppEnvironment {
    var share: ShareEnvironment {
        ShareEnvironment(
            shareClient: .live,
            mainQueue: mainQueue
        )
    }
}
