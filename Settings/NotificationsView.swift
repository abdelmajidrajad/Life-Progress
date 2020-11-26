import SwiftUI
import Core
import ComposableArchitecture


public struct NotificationsState: Equatable {
    public var reminderTime: Float
    var isAuthorized: Bool
    var isEndNotificationActivated: Bool
    var isCustomNotificationEnabled: Bool
    public init(
        isAuthorized: Bool = false,
        isEndNotificationEnabled: Bool = false,
        isCustomNotificationEnabled: Bool = false,
        reminderTime: Float = 0.5
    ) {
        self.reminderTime = reminderTime
        self.isAuthorized = isAuthorized
        self.isEndNotificationActivated = isEndNotificationEnabled
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
            state.reminderTime = userDefaults.taskNotificationPercent ?? 0.75
            state.isAuthorized = userDefaults.notificationsEnabled
            state.isEndNotificationActivated = userDefaults.endNotificationsEnabled
            state.isCustomNotificationEnabled = userDefaults.customNotificationsEnabled
            return .none
        case let .didAuthorized(newState):
            state.isAuthorized = newState
            userDefaults.notificationsEnabled = newState
            return !newState ? .concatenate(
                Effect(value: .didAuthorizedEnd(false)),
                Effect(value: .didAuthorizedCustom(false))
            ) : .none
        case let .didAuthorizedEnd(newState):
            state.isEndNotificationActivated = newState
            userDefaults.endNotificationsEnabled = newState
            return newState ? Effect(value: .didAuthorized(newState)): .none
        case let .didAuthorizedCustom(newState):
            userDefaults.customNotificationsEnabled = newState
            state.isCustomNotificationEnabled = newState
            return newState ? Effect(value: .didAuthorized(newState)): .none
        case let .didSlide(value):
            state.reminderTime = value
            userDefaults.taskNotificationPercent = value
            return .none
        }
}


private let percentage: (Float) -> String = {
    percentFormatter().string(from: NSNumber(value: $0)) ?? ""
}

extension NotificationsState {
    var view: NotificationsView.ViewState {
        NotificationsView.ViewState(
            firstTitle: "Allow notifications to get feedback when any task you started ended.",
            secondTitle: "Receive notification when any task you started reach 100%",
            thirdTitle: "Receive notification when any task you started reach " + percentage(reminderTime),
            isNotificationEnabled: isAuthorized,
            isEndNotificationEnabled: isEndNotificationActivated,
            isCustomNotificationEnabled: isCustomNotificationEnabled,
            reachingPoint: reminderTime,
            percent: percentage(reminderTime)
        )
    }
}


struct NotificationsView: View {
    
    struct ViewState: Equatable {
        let firstTitle: String
        let secondTitle: String
        let thirdTitle: String
        let isNotificationEnabled: Bool
        let isEndNotificationEnabled: Bool
        let isCustomNotificationEnabled: Bool
        let reachingPoint: Float
        let percent: String
    }
    
    let store: Store<NotificationsState, NotificationsAction>
    init(store: Store<NotificationsState, NotificationsAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store.scope(state: \.view)) { viewStore in
            List {
                Section(footer:
                            Text(viewStore.firstTitle)
                                .font(.preferred(.py_footnote()))
                ) {
                    Toggle(
                        "Allow Notifications",
                        isOn: viewStore.binding(
                            get: \.isNotificationEnabled,
                            send: NotificationsAction.didAuthorized
                        ))
                        .padding()
                }
                
                Section(footer:
                            Text(viewStore.secondTitle)
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
                        Text(viewStore.thirdTitle)
                            .font(.preferred(.py_footnote()))
                ) {
                    Toggle(
                        "Receive Notification when task reach " + viewStore.percent,
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
                        
                        Text(viewStore.percent)
                            .font(.preferred(.py_subhead()))
                            .foregroundColor(Color(.label))
                            .frame(
                                width: .py_grid(10),
                                height: .py_grid(10)
                            )
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
