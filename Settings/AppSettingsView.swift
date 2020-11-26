import SwiftUI
import Core
import ComposableArchitecture


public struct MoreSettingsState: Equatable {
    public enum Section: Equatable {
        case life
        case day
    }
    var lifeSetting: LifeSettingState
    var yourDaySetting: YourDaySettingsState
    public var section: Section?
    
    public init(
        lifeSetting: LifeSettingState = LifeSettingState(),
        yourDaySetting: YourDaySettingsState = YourDaySettingsState(),
        section: Section? = nil
    ) {
        self.lifeSetting = lifeSetting
        self.yourDaySetting = yourDaySetting
        self.section = section
    }
    
}
public enum MoreSettingsAction: Equatable {
    case sectionTapped(MoreSettingsState.Section?)
    case life(LifeSettingAction)
    case day(YourDaySettingsAction)
}

public struct MoreSettingsEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let userDefaults: KeyValueStoreType
    let ubiquitousStore: KeyValueStoreType
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

let moreSettingsReducer =
    Reducer<MoreSettingsState, MoreSettingsAction, MoreSettingsEnvironment>.combine(
        Reducer { state, action, _ in
            switch action {
            case let .sectionTapped(newSection):
                state.section = newSection
                return .none
            case .life, .day:
                return .none
            }
        },
        lifeSettingReducer.pullback(
            state: \.lifeSetting,
            action: /MoreSettingsAction.life,
            environment: {
                LifeSettingEnvironment(
                    calendar: $0.calendar,
                    date: $0.date,
                    userDefaults: $0.userDefaults,
                    ubiquitousStore: $0.ubiquitousStore,
                    mainQueue: $0.mainQueue
                )                
            }
        ),
        yourDayReducer.pullback(
            state: \.yourDaySetting,
            action: /MoreSettingsAction.day,
            environment: {
                YourDaySettingsEnvironment(
                    date: $0.date,
                    calendar: $0.calendar,
                    userDefaults: $0.userDefaults,
                    ubiquitiousStore: $0.ubiquitousStore,
                    mainQueue: $0.mainQueue
                )
            }
        )
    
    
    )

struct AppSettingsView: View {
    
    let store: Store<MoreSettingsState, MoreSettingsAction>
    
    public init(store: Store<MoreSettingsState, MoreSettingsAction>) {
        self.store = store
    }
    
    var body: some View {
        
        WithViewStore(store) { viewStore in
            List {
                NavigationLink(
                    destination:
                        LifeSettingView(store: store.scope(
                                state: \.lifeSetting,
                                action: MoreSettingsAction.life
                        )).navigationBarTitle(Text("Life Progress"), displayMode: .inline)
                        
                    ,
                    tag: MoreSettingsState.Section.life,
                    selection: viewStore.binding(
                        get: \.section,
                        send: MoreSettingsAction.sectionTapped
                    ),
                    label: {
                        HStack {
                            LeftImage(
                                systemName: "heart.fill",
                                fillColor: .pink
                            )
                            Text("Configure Life")
                                .font(.preferred(.py_body()))
                                .foregroundColor(Color(.label))
                        }.padding(.vertical, .py_grid(1))
                    })
                
                
                NavigationLink(
                    destination:
                        YourDaySettingView(store:
                                    store.scope(
                                            state: \.yourDaySetting,
                                            action: MoreSettingsAction.day)
                        )
                    ,
                    tag: .day,
                    selection: viewStore.binding(
                        get: \.section,
                        send: MoreSettingsAction.sectionTapped
                    ),
                    label: {
                        HStack {
                            LeftImage(
                                systemName: "clock.fill",
                                fillColor: .orange
                            )
                            Text("Configure Your day")
                                .font(.preferred(.py_body()))
                                .foregroundColor(Color(.label))
                        }.padding(.vertical, .py_grid(1))
                    })
                                                    
            }
        }
    }
}

struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppSettingsView(store: Store<MoreSettingsState, MoreSettingsAction>(
                                initialState: MoreSettingsState(),
                                reducer: .empty,
                                environment: ()
            ))
                .navigationBarTitle(Text("More"))
        }
    }
}
