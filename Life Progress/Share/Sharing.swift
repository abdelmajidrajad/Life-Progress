import ComposableArchitecture
import UIKit
import SwiftUI
import Combine
import Core


public struct ShareEnvironment {
    let shareClient: ShareClient
    let mainQueue: AnySchedulerOf<DispatchQueue>
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
        return share([image, URL(string: "https://apps.apple.com/us/app/year-progress/id1527416109")!])
            .receive(on: DispatchQueue.main.eraseToAnyScheduler())
            .eraseToEffect()
            .fireAndForget()
    case .nextButtonTapped:
        if state.currentIndex + 1 >= state.numberOfStates {
            state.currentIndex = 0
        } else {
            state.currentIndex += 1
        }
        return .none
    case .previousButtonTapped:
        if state.currentIndex == .zero  {
            state.currentIndex = state.numberOfStates - 1
        } else {
            state.currentIndex -= 1
        }
        return .none
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
            shareClient: shareClient,
            mainQueue: mainQueue
        )
    }
}
