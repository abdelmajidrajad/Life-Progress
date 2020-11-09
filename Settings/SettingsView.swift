import SwiftUI
import Core
import ComposableArchitecture

public enum SettingItem: Equatable, Identifiable {
    public var id: UUID { UUID() }
    case main
    case appIcon
    case showSettings
    case nightMode
    case notifications
    case rateUs
    case support
    case about
}

public struct SettingsState: Equatable {
    var aboutsState: AboutsState
    var appIconState: AppIconState
    var features: AppFeatureState
    var notifications: NotificationsState
    var section: SettingItem?
    var isURLOpenned: Bool = false
    public init(
        features: [Feature] = appFeatures,
        section: SettingItem? = nil
    ) {
        self.notifications = NotificationsState()
        self.appIconState = AppIconState()
        self.aboutsState = AboutsState(features: features)
        self.features = AppFeatureState(features: features)
        self.section = section
    }
}

public enum SettingAction: Equatable {
    case sectionTapped(SettingItem?)
    case isURLOpenned(Bool)
    case mainCellTapped
    case appIconCellTapped
    case nightModeCellTapped
    case rateUsCellTapped
    case supportCellTapped
    case aboutCellTapped
    case features(AppFeatureAction)
    case notifications(NotificationsAction)
    case appIcon(AppIconAction)
}


public struct SettingsEnvironment {
    let userDefaults: KeyValueStoreType
    public init(userDefaults: KeyValueStoreType) {
        self.userDefaults = userDefaults
    }
}

public let settingReducer =
    Reducer<SettingsState, SettingAction, SettingsEnvironment>.combine(
        Reducer {
            state, action, _ in
            switch action {
            case .mainCellTapped:
                return .none
            case .appIconCellTapped:
                return .none
            case .nightModeCellTapped:
                return .none
            case .rateUsCellTapped:
                return openURL(reviewURL(appId: "1527416109"))
                    .map(SettingAction.isURLOpenned)
                    .eraseToEffect()
            case .supportCellTapped:
                state.section = .support
                return .none
            case .aboutCellTapped:
                state.section = .about
                return .none
            case let .sectionTapped(section):
                state.section = section
                return .none
            case let .isURLOpenned(isOpen):
                state.isURLOpenned = isOpen
                return .none
            case .appIcon, .notifications, .features:
                return .none
            }
        },
        appIconReducer.pullback(
            state: \.appIconState,
            action: /SettingAction.appIcon,
            environment: { _ in () }
        ),
        notificationReducer.pullback(
            state: \.notifications,
            action: /SettingAction.notifications,
            environment: { $0.userDefaults }
        ),
        appFeatureReducer.pullback(
            state: \.features,
            action: /SettingAction.features,
            environment: { _ in () }
        )
    )


public struct SettingsView: View {
    
    let store: Store<SettingsState, SettingAction>
    
    public init(
        store: Store<SettingsState, SettingAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Section {
                    //MARK:- Life Progress
                    HStack(spacing: .py_grid(4)) {
                        Image("classic", bundle: .settings)
                            .resizable()
                            .frame(
                                width: .py_grid(16),
                                height: .py_grid(16)
                            ).clipShape(
                                RoundedRectangle(
                                    cornerRadius: .py_grid(4),
                                    style: .continuous
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: .py_grid(2)) {
                            Text("Life Progress PLUS+".uppercased())
                                .font(
                                    Font.preferred(
                                        .py_title3())
                                        .bold()
                                        .smallCaps()
                                )
                            Text("Progress your tasks")
                                .font(.preferred(.py_body()))
                        }
                    }.padding(.vertical)
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .background(
                         Color(.secondarySystemGroupedBackground)
                     ).sheet(isPresented: viewStore.binding(
                                get: { $0.section == .main },
                                send: { _ in .sectionTapped(nil) }),
                             content: {
                                AppFeaturesView(store: store.scope(
                                    state: \.features,
                                    action: SettingAction.features
                                ))
                     })
                    .onTapGesture {
                        viewStore.send(.sectionTapped(.main))
                    }
                    
                    //MARK:- App Icon
                    NavigationLink(
                        destination: AppIconsView(
                            store: store.scope(
                                state: \.appIconState,
                                action: SettingAction.appIcon
                            )
                        ),
                        tag: .appIcon,
                        selection: viewStore.binding(
                            get: \.section,
                            send: SettingAction.sectionTapped
                        ),
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "a.circle.fill",
                                    fillColor: .green
                                )
                                Text("App Icon")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        })
                    
                    //MARK:- Show Settings
                    //NavigationLink(
                    //    destination: Text("Settings"),
                    //    tag: .showSettings,
                    //    selection: $section,
                    //    label: {
                    //        HStack {
                    //            LeftImage(
                    //                systemName: "wrench.fill",
                    //                fillColor: .gray
                    //            )
                    //            Text("Show Settings")
                    //                .font(.preferred(.py_body()))
                    //        }.padding(.vertical, .py_grid(1))
                    //})
                }
                
                Section {
                    //MARK:- Night Mode
                    NavigationLink(
                        destination: NightModeView(),
                        tag: .nightMode,
                        selection: viewStore.binding(
                            get: \.section,
                            send: SettingAction.sectionTapped
                        ),
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "moon.fill",
                                    fillColor: .purple
                                )
                                Text("Night Mode")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        })
                    
                    //MARK:- Notifications
                    NavigationLink(
                        destination:
                        NotificationsView(store:
                                    store.scope(
                                    state: \.notifications,
                                    action: SettingAction.notifications)
                        ),
                        tag: .notifications,
                        selection: viewStore.binding(
                            get: \.section,
                            send: SettingAction.sectionTapped
                        ),
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "app.badge",
                                    fillColor: .red
                                )
                                Text("Notifications")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        })
                    
                }
                
                
                Section {
                    //MARK:- App Store Rating
                    HStack {
                        LeftImage(
                            systemName: "star.fill",
                            fillColor: .blue
                        )
                        Text("Please Rate on App Store")
                            .font(.preferred(.py_body()))
                    }.padding(.vertical, .py_grid(1))
                    .onTapGesture {
                        viewStore.send(.rateUsCellTapped)
                    }
                }
                
                Section {
                    //MARK:- Support
                    HStack {
                        LeftImage(
                            systemName: "questionmark",
                            fillColor: .orange
                        )
                        Text("Support")
                            .font(.preferred(.py_body()))
                    }.padding(.vertical, .py_grid(1))
                    .sheet(
                        isPresented: viewStore.binding(
                            get: { $0.section == .support },
                            send: { _ in .sectionTapped(nil) }),
                        content: {
                            SupportView(onDismiss: viewStore.send(.sectionTapped(nil))
                            )
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .onTapGesture {
                        viewStore.send(.supportCellTapped)
                    }
                    
                    //MARK:- About
                    NavigationLink(
                        destination: AboutsView(
                            store: store.scope(state: \.aboutsState).actionless
                        ),
                        tag: .about,
                        selection: viewStore.binding(
                            get: \.section,
                            send: SettingAction.sectionTapped
                        ),
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "exclamationmark",
                                    fillColor: .pink
                                )
                                Text("About")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        })
                    }
                
            }.navigationBarTitle(
                Text("Settings"),
                displayMode: .inline
            ).listStyle(GroupedListStyle())
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SettingsView(store: Store<SettingsState, SettingAction>(
                                initialState: SettingsState(),
                                reducer: settingReducer,
                                environment:
                                    SettingsEnvironment(
                                        userDefaults: TestUserDefault())
                                )
                )
            }
            NavigationView {
                SettingsView(store: Store<SettingsState, SettingAction>(
                                initialState: SettingsState(),
                                reducer: settingReducer,
                                environment:
                                    SettingsEnvironment(
                                        userDefaults: TestUserDefault())
                            )
                )
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct LeftImage: View {
    let systemName: String
    let fillColor: Color
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(.white)
            .font(.headline)
            .frame(width: .py_grid(10), height: .py_grid(10))
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(3),
                    style: .continuous
                ).fill(fillColor)
            )
    }
}

let openURL: (URL) -> Effect<Bool, Never> = { url in
    .future { promise in
        UIApplication
            .shared
            .open(url, options: [:]) { isOpenned in
                promise(.success(isOpenned))
            }
    }
}

public func reviewURL(appId: String) -> URL {
    URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(appId)?mt=8&action=write-review")!
}

// App Icons
public enum AppIcon: String, CaseIterable {
    case classic
    case blue
    case orange
    case purple
    case red
}

var currentAppIcon: AppIcon {
    AppIcon
        .allCases
        .first { $0.rawValue == UIApplication.shared.alternateIconName }
        ?? .classic
}

import Combine
let newIcon: (AppIcon) -> AnyPublisher<Bool, Never> = { appIcon in
    guard UIApplication.shared.supportsAlternateIcons,
          currentAppIcon != appIcon else {
        return Just(false).eraseToAnyPublisher() }
    
    return Deferred { Future<Bool, Never> { promise in
        UIApplication.shared.setAlternateIconName(appIcon.rawValue) {
            promise(.success($0 != nil))
        }
    }}.eraseToAnyPublisher()
}
