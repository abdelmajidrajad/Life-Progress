import SwiftUI
import Core
import ComposableArchitecture


public struct NotificationsState: Equatable {
    public var reachingPoint: Float
    var isAuthorized: Bool
    var isEndNotificationEnabled: Bool
    var isCustomNotificationEnabled: Bool
    public init(
        isAuthorized: Bool = false,
        isEndNotificationEnabled: Bool = false,
        isCustomNotificationEnabled: Bool = false,
        reachingPoint: Float = 0.5
    ) {
        self.reachingPoint = reachingPoint
        self.isAuthorized = isAuthorized
        self.isEndNotificationEnabled = isEndNotificationEnabled
        self.isCustomNotificationEnabled = isCustomNotificationEnabled
    }
}

public enum NotificationsAction: Equatable {
    case onAppear
    case didAuthorized(Bool)
    case didAuthorizedEnd(Bool)
    case didAuthorizedCustom(Bool)
    case didSlide(Float)
}

struct NotificationEnvironment {
    let userDefaults: KeyValueStoreType
    let notificationClient: NotificationClient
}

public let notificationReducer =
    Reducer<NotificationsState, NotificationsAction, KeyValueStoreType> {
        state, action, userDefaults in
        switch action {
        case .onAppear:
            state.isAuthorized = UIApplication
                .shared
                .isRegisteredForRemoteNotifications
            state.isEndNotificationEnabled = userDefaults.bool(forKey: "tasks.notifications.end")
            state.isCustomNotificationEnabled = userDefaults.bool(forKey: "tasks.notifications.custom")
            return .none
        case let .didAuthorized(newState):
            state.isAuthorized = newState
            return .none
        case let .didAuthorizedEnd(newState):
            state.isEndNotificationEnabled = newState
            userDefaults.set(newState, forKey: "tasks.notifications.end")
            return .none
        case let .didAuthorizedCustom(newState):
            userDefaults.set(newState, forKey: "tasks.notifications.custom")
            state.isCustomNotificationEnabled = newState
            return .none
        case let .didSlide(value):
            state.reachingPoint = value
            return .none
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
                        "Allow Notifications",
                        isOn: viewStore.binding(
                            get: \.isAuthorized,
                            send: NotificationsAction.didAuthorized
                        ))
                        .padding()
                }
                
                Section(footer:
                    Text("Receive notification when any task you started reach 100%")
                            .font(.preferred(.py_footnote()))
                ) {
                    Toggle(
                        "Receive Notification at the end",
                        isOn: viewStore.binding(
                            get: \.isEndNotificationEnabled,
                            send: NotificationsAction.didAuthorizedEnd
                        )
                    ).padding()
                }
                
                Section(footer:
                    Text("Receive notification when any task you started reach " + (percentFormatter().string(from: NSNumber(value: viewStore.reachingPoint)) ?? ""))
                            .font(.preferred(.py_footnote()))
                ) {
                    Toggle(
                        "Receive Notification at half",
                        isOn: viewStore.binding(
                            get: \.isCustomNotificationEnabled,
                            send: NotificationsAction.didAuthorizedCustom
                        )
                    ).padding()
                    
                    HStack {
                        Slider(
                            value: viewStore.binding(
                                get: \.reachingPoint,
                                send: NotificationsAction.didSlide
                            ),
                            in: 0...1,
                            step: 0.05
                        ).accentColor(Color(.label))
                        Text(percentFormatter().string(from: NSNumber(value: viewStore.reachingPoint)) ?? "")
                            .font(.preferred(.py_subhead()))
                            .foregroundColor(Color(.label))
                            .frame(width: .py_grid(10), height: .py_grid(10))
                            .background(
                                RoundedRectangle(cornerRadius: .py_grid(4))
                                    .fill(Color(.label).opacity(0.1))
                            )
                    }
                                                                    
                }
                
            }.font(.preferred(.py_subhead()))
             .listStyle(GroupedListStyle())
             .onAppear { viewStore.send(.onAppear) }
             .foregroundColor(Color(.label))
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
