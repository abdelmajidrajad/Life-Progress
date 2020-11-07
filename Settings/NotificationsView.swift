import SwiftUI
import Core
import ComposableArchitecture


public struct NotificationsState: Equatable {
    var isAuthorized: Bool
    var isReceivingActivated: Bool
    public init(
        isAuthorized: Bool = false,
        isReceivingActivated: Bool = false
    ) {
        self.isAuthorized = isAuthorized
        self.isReceivingActivated = isReceivingActivated
    }
}

public enum NotificationsAction: Equatable {
    case onAppear
    case allowToggle(Bool)
    case getToggle(Bool)
}

public let notificationReducer =
    Reducer<NotificationsState, NotificationsAction, KeyValueStoreType> {
        state, action, userDefaults in
        switch action {
        case .onAppear:
            state.isAuthorized = UIApplication
                .shared
                .isRegisteredForRemoteNotifications
            state.isReceivingActivated = userDefaults.bool(forKey: "tasks.notifications")
            return .none
        case let .allowToggle(newState):
            state.isAuthorized = newState
            return .fireAndForget {
                newState
                ? UIApplication.shared.registerForRemoteNotifications()
                : UIApplication.shared.unregisterForRemoteNotifications()
            }
        case let .getToggle(newState):
            state.isReceivingActivated = newState
            return .fireAndForget {
                userDefaults.set(newState, forKey: "tasks.notifications")
                newState
                    ? ()
                    : UNUserNotificationCenter
                        .current()
                        .removeAllPendingNotificationRequests()
            }
        }
}


struct NotificationsView: View {
    let store: Store<NotificationsState, NotificationsAction>
    init(store: Store<NotificationsState, NotificationsAction>) {
        self.store = store
    }
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Section(footer:
                    Text("Allow notifications to get feedback when any task you started ended.")
                            .font(.preferred(.py_footnote()))
                ) {
                    Toggle(
                        "Allow Notification",
                        isOn: viewStore.binding(
                            get: \.isAuthorized,
                            send: NotificationsAction.allowToggle
                        ))
                        .padding()
                }
                
                Section(footer:
                    Text("Receive notification when any task you started reach the end")
                            .font(.preferred(.py_footnote()))
                ) {
                    Toggle(
                        "Get Notification When 100%",
                        isOn: viewStore.binding(
                            get: \.isReceivingActivated,
                            send: NotificationsAction.getToggle
                        )
                    ).padding()
                        
                }
                
            }.font(.preferred(.py_subhead()))
             .listStyle(GroupedListStyle())
            .onAppear { viewStore.send(.onAppear) }
        }.navigationBarTitle(Text("Notifications"))
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NotificationsView(store: Store<NotificationsState, NotificationsAction>(
                initialState: NotificationsState(),
                reducer: notificationReducer,
                environment: TestUserDefault()
            ))
            NavigationView {
                NotificationsView(store: Store<NotificationsState, NotificationsAction>(
                    initialState: NotificationsState(),
                    reducer: notificationReducer,
                    environment: TestUserDefault()
                )).preferredColorScheme(.dark)
                .navigationBarTitle(Text("Notifications"))
                
            }
        }
    }
}
