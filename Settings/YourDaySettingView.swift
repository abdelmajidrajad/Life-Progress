import SwiftUI
import Core
import ComposableArchitecture

public struct YourDaySettingsState: Equatable {
    var startDate: Date
    var endDate: Date
    var startOfDay: Date
    var endOfDay: Date
    var dayHours: Double
    public init(
        startDate: Date = Date().addingTimeInterval(-3600 * 10),
        endDate: Date = Date().addingTimeInterval(3600 * 10),
        startOfDay: Date = Date().addingTimeInterval(-3600 * 11),
        endOfDay: Date = Date().addingTimeInterval(3600 * 11),
        dayHours: Double = .zero
    )  {
        self.startDate = startDate
        self.endDate = endDate
        self.startOfDay = startOfDay
        self.endOfDay = endOfDay
        self.dayHours = dayHours
    }
}

public enum YourDaySettingsAction: Equatable {
    case doneButtonTapped
    case cancelButtonTapped
    case onAppear
    case didStartDateChanged(Date)
    case didEndDateChanged(Date)
    case dayHours
}

public struct YourDaySettingsEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let userDefaults: KeyValueStoreType
    let mainQueue: AnySchedulerOf<DispatchQueue>
    public init(
        date: @escaping () -> Date,
        calendar: Calendar,
        userDefaults: KeyValueStoreType,
        mainQueue: AnySchedulerOf<DispatchQueue>
    )  {
        self.date = date
        self.calendar = calendar
        self.userDefaults = userDefaults
        self.mainQueue = mainQueue
    }
}

public let yourDayReducer = Reducer<YourDaySettingsState, YourDaySettingsAction, YourDaySettingsEnvironment> { state, action, environment in
    switch action {
    case .doneButtonTapped:
        return .none
    case .cancelButtonTapped:
        return .none
    case .onAppear:
        
        state.startOfDay = environment
            .calendar
            .startOfDay(for: environment.date())
        
        state.endOfDay = environment
            .calendar
            .dayEnd(of: environment.date())
        
        state.startDate = environment.userDefaults.object(forKey: "startDate") as? Date
            ?? environment.calendar
                .date(
                    bySettingHour: 08,
                    minute: 00,
                    second: 00,
                    of: environment.date()
                )!
            
        state.endDate = environment.userDefaults.object(forKey: "endDate") as? Date
            ?? environment
                .calendar.date(
                    bySettingHour: 18,
                    minute: 00,
                    second: 00,
                    of: environment.date()
                )!
        
        return Effect(value: .dayHours)
    case let .didStartDateChanged(date):
        struct StartDateId: Hashable {}
        state.startDate = date
        return .concatenate(
            Effect.fireAndForget {
                environment.userDefaults
                    .set(date, forKey: "startDate")
            }.debounce(
                id: StartDateId(),
                for: 2.0,
                scheduler: environment.mainQueue
            ),
            Effect(value: .dayHours)
        )
    case let .didEndDateChanged(date):
        struct EndDateId: Hashable {}
        state.endDate = date
        return .concatenate(
            Effect.fireAndForget {
                environment.userDefaults
                    .set(date, forKey: "endDate")
            }.debounce(
                id: EndDateId(),
                for: 2.0,
                scheduler: environment.mainQueue
            ),
            Effect(value: .dayHours)
        )
    case .dayHours:
        
        let component = environment.calendar
            .dateComponents([.hour, .minute],
                            from: state.startDate,
                            to: state.endDate
            )
        
        state.dayHours = Double(component.hour!) + Double(component.minute!) / 60
        return .none
    }
}


let firstStep: (Date) -> Double = {
    let components = Calendar.current.dateComponents([.hour, .minute], from: $0)
    guard let hour = components.hour,
          let minute = components.minute else { return .zero }
    return Double(hour) + Double(minute / 60)
}


extension YourDaySettingsState {
    var view: YourDaySettingView.ViewState {
        .init(
            startDate: startDate,
            endDate: endDate,
            startClosedRange: startOfDay...endDate,
            endClosedRange: startDate...endOfDay.addingTimeInterval(3600),
            dayHours: Double(dayHours),
            startHour: firstStep(startDate)
        )
    }
}


struct YourDaySettingView: View {
    
    struct ViewState: Equatable {
        let startDate: Date
        let endDate: Date
        let startClosedRange: ClosedRange<Date>
        let endClosedRange: ClosedRange<Date>
        let dayHours: Double
        let startHour: Double
    }
    
    let store: Store<YourDaySettingsState, YourDaySettingsAction>
    public init(store: Store<YourDaySettingsState, YourDaySettingsAction>) {
        self.store = store
    }
    var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
                                                           
            ScrollView(.vertical, showsIndicators: false) {
                
                SmartProgressBar(
                    maxSteps: 24,
                    firstStep: viewStore.startHour,
                    duration: viewStore.dayHours,
                    color: Color.green
                ).padding()
                
                VStack(spacing: .py_grid(2)) {
                    
                    HDashedLine(color: .green)
                    
                    Text("start at")
                        .font(
                            Font.preferred(.py_title3()).smallCaps().bold()
                        ).foregroundColor(.gray)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HDashedLine(color: .green)
                    
                    DatePicker("",
                               selection: viewStore.binding(
                                get: \.startDate,
                                send: YourDaySettingsAction.didStartDateChanged),
                               in: viewStore.startClosedRange,
                               displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                }
                
                VStack(spacing: .py_grid(2)) {
                    HDashedLine(color: .red)
                    Text("end at")
                        .font(
                            Font.preferred(.py_title3()).smallCaps().bold()
                        ).foregroundColor(.gray)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HDashedLine(color: .red)
                                                           
                    DatePicker("",
                               selection: viewStore.binding(
                                    get: \.endDate,
                                    send: YourDaySettingsAction.didEndDateChanged),
                               in: viewStore.endClosedRange,
                               displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    
                }.font(.headline)
                .accentColor(.red)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }.navigationBarItems(
                trailing: Button(action: {
                    viewStore.send(.doneButtonTapped)
                }) {
                    Text("Done")
                }
            ).navigationBarTitle(Text("Make Your Day"), displayMode: .inline)
            .environment(\.locale, Locale(identifier: "ma"))
            
        }
    }
}


struct YourDayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                YourDaySettingView(
                    store: Store(
                        initialState: YourDaySettingsState(),
                        reducer: yourDayReducer,
                        environment: YourDaySettingsEnvironment(
                            date: Date.init,
                            calendar: .current,
                            userDefaults: TestUserDefault(),
                            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                        ))
                )
            }
            YourDaySettingView(store: Store(
                            initialState: YourDaySettingsState(),
                            reducer: yourDayReducer,
                            environment: YourDaySettingsEnvironment(
                                date: Date.init,
                                calendar: Calendar(identifier: .iso8601),
                                userDefaults: TestUserDefault(),
                                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                            )))
                .preferredColorScheme(.dark)
        }
    }
}
