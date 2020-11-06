import SwiftUI
import Core
import ComposableArchitecture

enum SettingItem: Equatable {
    case appInfo
    case appIcon
    case showSettings
    case nightMode
    case rateUs
    case support
    case notifications
    case about
}


struct SettingsState: Equatable {
    var aboutsState: AboutsState
    var appIconState: AppIconState
    var section: SettingItem?
    init(
        features: [Feature] = appFeatures,
        section: SettingItem? = nil
    ) {
        self.appIconState = AppIconState()
        self.aboutsState = AboutsState(features: features)
        self.section = section
    }
}

enum SettingAction: Equatable {
    case sectionTapped(SettingItem?)
    case mainCellTapped
    case appIconCellTapped
    case nightModeCellTapped
    case rateUsCellTapped
    case supportCellTapped
    case aboutCellTapped
    case appIcon(AppIconAction)
}


let settingReducer = Reducer<SettingsState, SettingAction, Void>.combine(
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
            return .none
        case .supportCellTapped:
            return .none
        case .aboutCellTapped:
            return .none
        case let .sectionTapped(section):
            state.section = section
            return .none
        case .appIcon:
            return .none
        }
    },
    appIconReducer.pullback(
        state: \.appIconState,
        action: /SettingAction.appIcon,
        environment: { $0 }
    )   
)


public struct SettingsView: View {
        
    let store: Store<SettingsState, SettingAction>
    init(store: Store<SettingsState, SettingAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
                List {
                    Section {
                                            
                        //MARK:- Life Progress
                        NavigationLink(
                            destination: Text("Destination"),
                            tag: .appInfo,
                            selection: viewStore.binding(
                                get: \.section,
                                send: SettingAction.sectionTapped
                            ),
                            label: {
                                
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
                                
                            }).onTapGesture {
                                //self.section = .appInfo
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
                            destination: Text("Notifications"),
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
        NavigationView {
            SettingsView(store: Store<SettingsState, SettingAction>(
                            initialState: SettingsState(),
                            reducer: settingReducer,
                            environment: ())
            )
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


public let reviewURL: (String) -> URL = { appId in
     URL.init(string:"itms-apps:itunes.apple.com/us/app/apple-store/id\(appId)?mt=8&action=write-review")!
}

// App Icons
enum AppIcon: String, CaseIterable {
    case classic, blue, orange, purple, red
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
