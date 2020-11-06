import SwiftUI
import Core
import ComposableArchitecture
import TimeClient

public struct YourDayState: Equatable {
    var startDate: Date
    var endDate: Date
    var startOfDay: Date
    var endOfDay: Date
    var dayHours: Double
    public init(
        startDate: Date = Date(),
        endDate: Date = Date(),
        startOfDay: Date = Date(),
        endOfDay: Date = Date(),
        dayHours: Double = .zero
    )  {
        self.startDate = startDate
        self.endDate = endDate
        self.startOfDay = startOfDay
        self.endOfDay = endOfDay
        self.dayHours = dayHours
    }
}

public enum YourDayAction: Equatable {
    case doneButtonTapped
    case cancelButtonTapped
    case onAppear
    case didStartDateChanged(Date)
    case didEndDateChanged(Date)
    case dayHours
}

public struct YourDayEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let userDefaults: KeyValueStoreType
    public init(
        date: @escaping () -> Date,
        calendar: Calendar,
        userDefaults: KeyValueStoreType
    )  {
        self.date = date
        self.calendar = calendar
        self.userDefaults = userDefaults
    }
}

public let yourDayReducer = Reducer<YourDayState, YourDayAction, YourDayEnvironment> { state, action, environment in
    switch action {
    case .doneButtonTapped:
        return .none
    case .cancelButtonTapped:
        return .none
    case .onAppear:
        state.startOfDay = environment.calendar.startOfDay(for: environment.date())
        state.endOfDay = endOfDay(environment.date(), environment.calendar)
        state.startDate =
            environment.calendar
            .date(
                bySettingHour: 08,
                minute: 00,
                second: 00,
                of: environment.date()
            )
            ?? environment.date()
        state.endDate = environment
            .calendar.date(
                bySettingHour: 18,
                minute: 00,
                second: 00,
                of: environment.date())
            ?? environment.date()
        return Effect(value: .dayHours)
    case let .didStartDateChanged(date):
        state.startDate = date
        let dateComponents = environment.calendar
            .dateComponents(
                [.hour, .minute],
                from: date
            )
        return .concatenate(
            .fireAndForget {
                environment.userDefaults
                    .set(DateComponent(
                            hour: dateComponents.hour!,
                            minute: dateComponents.minute!),
                         forKey: "startDate")
            },
            Effect(value: .dayHours)
        )
    case let .didEndDateChanged(date):
        state.endDate = date
        let dateComponents = environment.calendar.dateComponents([.hour, .minute], from: date)
        return .concatenate(
            .fireAndForget {
                environment.userDefaults
                    .set(DateComponent(
                            hour: dateComponents.hour!,
                            minute: dateComponents.minute!),
                         forKey: "endDate")
            },
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


extension YourDayState {
    var view: YourDayView.ViewState {
        .init(
            startDate: startDate,
            endDate: endDate,
            startClosedRange: startOfDay...endDate,
            endClosedRange: startDate...endOfDay,
            dayHours: Double(dayHours),
            startHour: firstStep(startDate)
        )
    }
}


struct YourDayView: View {
    
    struct ViewState: Equatable {
        let startDate: Date
        let endDate: Date
        let startClosedRange: ClosedRange<Date>
        let endClosedRange: ClosedRange<Date>
        let dayHours: Double
        let startHour: Double
    }
    
    let store: Store<YourDayState, YourDayAction>
    public init(store: Store<YourDayState, YourDayAction>) {
        self.store = store
    }
    var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            ZStack(alignment: .top) {
                
                ZStack {
                    HStack {
                        Button(action: {
                            viewStore.send(.cancelButtonTapped)
                        }) {
                            Text("Cancel")
                        }
                        Spacer()
                        Button(action: {
                            viewStore.send(.doneButtonTapped)
                        }) {
                            Text("Done")
                        }
                    }.padding()
                    .background(
                        VisualEffectBlur()
                    ).font(.headline)
                    
                    Text("Make Your Day")
                        .font(Font.preferred(.py_title2()).smallCaps())
                        .frame(maxWidth: .infinity)
                }
                
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
                                    send: YourDayAction.didStartDateChanged),
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
                                    send: YourDayAction.didEndDateChanged),
                                   in: viewStore.endClosedRange,
                                   displayedComponents: [.hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    }
                }.font(.headline)
                .accentColor(.red)
                .padding(.top, .py_grid(20))                
            }.onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}


struct YourDayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            YourDayView(
                store: Store(
                    initialState: YourDayState(),
                    reducer: yourDayReducer,
                    environment: YourDayEnvironment(
                        date: Date.init,
                        calendar: .current,
                        userDefaults: TestUserDefault()
                    ))
            )
            YourDayView(store: Store(
                            initialState: YourDayState(),
                            reducer: yourDayReducer,
                            environment: YourDayEnvironment(
                                date: Date.init,
                                calendar: .current,
                                userDefaults: TestUserDefault()
                            )))
                .preferredColorScheme(.dark)
        }
    }
}
