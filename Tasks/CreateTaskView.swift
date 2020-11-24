import SwiftUI
import Core
import TimeClient
import Validated
import TaskClient
import Combine

func validate(title: String) -> Validated<String, String> {
    if !title.isEmpty {
        return .valid(title)
    }
    return .error("title is empty")
}

var dateFormatter: () -> DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a  d MMMM YYYY"
    return formatter
}

public struct CreateTaskState: Equatable {
    public var title: String
    public var isValidTitle: Bool
    public var startDate: Date
    public var endDate: Date
    public var today: Date
    public var chosenColor: Color
    public var progressStyle: ProgressStyle
    public var diff: TimeResult
    public var alert: AlertState<CreateTaskAction>?
    public var isRequestSucceed: Bool = false
    public init(
        taskTitle: String = "",
        isValidTitle: Bool = false,
        startDate: Date,
        endDate: Date,
        today: Date = Date(),
        chosenColor: Color = Color(.endBlueLightColor),
        progressStyle: ProgressStyle = .bar,
        diff: TimeResult = .zero,
        alert: AlertState<CreateTaskAction>? = nil,
        isRequestSucceed: Bool = false
    ) {
        self.title = taskTitle
        self.isValidTitle = isValidTitle
        self.startDate = startDate
        self.endDate = endDate
        self.chosenColor = chosenColor
        self.progressStyle = progressStyle
        self.diff = diff
        self.alert = alert
        self.isRequestSucceed = isRequestSucceed
        self.today = today
    }
}

public enum CreateTaskAction: Equatable {
    case onAppear
    case response(Result<TaskResponse, TaskFailure>)
    case notificationResponse(Result<NotificationClient.Response, NotificationClient.Failure>)
    case startButtonTapped
    case selectStyle(ProgressStyle)
    case diff(TimeResult)
    case titleChanged(String)
    case validation(Validated<String, String>)
    case selectColor(Color)
    case reset
    case alertDismissed
    case cancelButtonTapped
    //case endDate(DateControlAction)
    //case startDate(DateControlAction)
    case endDate(Date)
    case startDate(Date)
}

import CoreData
public struct CreateTaskEnvironment {
    let uuid: () -> UUID
    let date: () -> Date
    let calendar: Calendar
    let timeClient: TimeClient
    let managedContext: NSManagedObjectContext
    let taskClient: TaskClient
    let notificationClient: NotificationClient
    public init(
        uuid: @escaping () -> UUID,
        date: @escaping () -> Date,
        calendar: Calendar,
        timeClient: TimeClient,
        taskClient: TaskClient,
        managedContext: NSManagedObjectContext,
        notificationClient: NotificationClient
    ) {
        self.uuid = uuid
        self.date = date
        self.calendar = calendar
        self.timeClient = timeClient
        self.taskClient = taskClient
        self.managedContext = managedContext
        self.notificationClient = notificationClient
    }
}


import ComposableArchitecture
public let createTaskReducer: Reducer<CreateTaskState, CreateTaskAction, CreateTaskEnvironment> =
    Reducer { state, action, environment in
        switch action {
        case .startButtonTapped:
            let uuid = environment.uuid()
            return .concatenate(
                environment.taskClient.create(
                    TaskRequest(
                        viewContext: environment.managedContext,
                        task: ProgressTask(
                            id: uuid,
                            title: state.title,
                            startDate: state.startDate,
                            endDate: state.endDate,
                            creationDate: environment.date(),
                            color: state.chosenColor.uiColor(),
                            style: state.progressStyle == .bar ? .bar: .circle
                        )
                    )
                ).catchToEffect()
                .map(CreateTaskAction.response),
                environment.notificationClient.send(
                    NotificationClient.Request(
                        notification: LocalNotification(
                            identifier: uuid.uuidString,
                            title: "Your Task Ended",
                            subtitle: state.title,
                            message: "Reach 100%"
                        ),
                        date: state.endDate
                    )).catchToEffect()
                    .map(CreateTaskAction.notificationResponse)
            )
        case let .selectStyle(style):
            state.progressStyle = style
            return .none
        case .reset:
            state.startDate = environment.date()
            state.endDate = environment.date().addingTimeInterval(3600 * 24)
            state.diff = .zero
            return .none
        case let .titleChanged(title):
            state.title = title
            return Effect(value:
                    .validation(validate(title: title)))
        case let .selectColor(color):
            state.chosenColor = color
            return .none
        case let .startDate(startDate):
            state.startDate = startDate
            if startDate >= state.endDate {
                state.endDate = startDate
            }
            return environment
                .timeClient
                .taskProgress(
                    ProgressTaskRequest(
                        currentDate: environment.date(),
                        calendar: environment.calendar,
                        startAt: state.startDate,
                        endAt: state.endDate
                    )).map(\.result)
                .map(CreateTaskAction.diff)
                .eraseToEffect()
        case let .endDate(date):
            if date > state.startDate {
                state.endDate = date
            }
            return environment
                .timeClient
                .taskProgress(ProgressTaskRequest(
                    currentDate: environment.date(),
                    calendar: environment.calendar,
                    startAt: state.startDate,
                    endAt: state.endDate
                )).map(\.result)
                .map(CreateTaskAction.diff)
                .eraseToEffect()
        case let .diff(result):
            state.diff = result
            return .none
        case .onAppear:
            state.today = environment.date()
            return .none
        case .validation(.valid):
            state.isValidTitle = true
            return .none
        case .validation(.invalid(_)):
            state.isValidTitle = false
            return .none
        case .response(.success):
            return .none
        case let .response(.failure(error)):
            state.alert = AlertState(
                title: LocalizedStringKey("Alert"),
                message: LocalizedStringKey(error.errorDescription),
                dismissButton: .cancel(send: .alertDismissed)
            )
            return .none
        case .alertDismissed:
            state.alert = nil
            return .none
        case .cancelButtonTapped:
            return .none
        case .notificationResponse(_):
            return .none
        }
    }



extension CreateTaskState {
    var view: CreateTaskView.ViewState {
        .init(
            title: title,
            startDate: startDate,
            endDate: endDate,
            startDateRange: today...endDate,
            chosenColor: chosenColor,
            progressStyle: progressStyle,
            diff: diff.string(widgetStyle, style: .long),
            isDiff: diff != .zero,
            isValid: isValidTitle && diff != .zero
        )
    }
}

public struct CreateTaskView: View {
    public struct ViewState: Equatable {
        public var title: String
        public var startDate: Date
        public var endDate: Date
        public var startDateRange: ClosedRange<Date>
        public var chosenColor: Color
        public var progressStyle: ProgressStyle
        public var diff: NSAttributedString
        public var isDiff: Bool
        public var isValid: Bool
    }
    @Environment(\.presentationMode) var presentationMode
    
    let store: Store<CreateTaskState, CreateTaskAction>
    
    public init(store: Store<CreateTaskState, CreateTaskAction>) {
        self.store = store
    }
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
           
            ZStack(alignment: .bottom) {
                
                ZStack(alignment: .top) {
                                                            
                    ZStack(alignment: .leading) {
                        Button(action: {
                            self.presentationMode
                                .wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }.buttonStyle(CloseButtonCircleStyle())
                        .zIndex(1)
                        .padding(.leading, .py_grid(1))
                        
                        Text(.newTask)
                            .font(Font
                                    .preferred(.py_title3())
                                    .bold())
                            .frame(
                                maxWidth: .infinity,
                                alignment: .bottom
                            )
                    }
                    .background(
                        VisualEffectBlur()
                            .edgesIgnoringSafeArea(.top)
                    ).zIndex(2)
                                                
                    ScrollView(.vertical) {
                                                            
                        VStack {
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 100, height: 80)
                            
                            TextField(.taskTitle, text: viewStore.binding(
                                get: \.title,
                                send: CreateTaskAction.titleChanged
                            ))
                            .font(Font.preferred(.py_title3()).bold())
                            .padding()
                        }
                        
                        HDashedLine(color: viewStore.isValid
                                        ? Color(.secondaryLabel)
                                        : .red
                        )
                        
                        DatePicker(.startDate, selection: viewStore.binding(
                            get: \.startDate,
                            send: CreateTaskAction.startDate
                        ),
                        in: viewStore.startDateRange,
                        displayedComponents:
                            DatePickerComponents(
                                arrayLiteral: .date, .hourAndMinute)
                        ).padding()
                        .font(Font.preferred(.py_subhead()).smallCaps())
                        .foregroundColor(Color(.label))
                        .accentColor(viewStore.chosenColor)
                                                                        
                        HDashedLine()
                        
                        DatePicker(.endDate, selection: viewStore.binding(
                            get: \.endDate,
                            send: CreateTaskAction.endDate
                        ), in: PartialRangeFrom(viewStore.startDate),
                        displayedComponents: DatePickerComponents(arrayLiteral: .hourAndMinute, .date))
                        .padding()
                        .font(Font.preferred(.py_subhead()).smallCaps())
                        .foregroundColor(Color(.label))
                        .accentColor(viewStore.chosenColor)
                        
                        
                        HDashedLine()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Spacer(minLength: .py_grid(2))
                                
                                if #available(iOS 14.0, *) {
                                    ColorPicker("",
                                    selection:
                                    viewStore.binding(
                                        get: \.chosenColor,
                                        send: CreateTaskAction.selectColor
                                    ))
                                    .frame(
                                        width: .py_grid(10),
                                        height: .py_grid(10)
                                    ).labelsHidden()
                                }
                                
                                ForEach(colors(), id: \.self) { color in
                                    RoundedRectangle(
                                        cornerRadius: .py_grid(3),
                                        style: .continuous
                                    ).fill(color
                                            .opacity(
                                                viewStore.chosenColor == color
                                                    ? 1
                                                    : 0.3)
                                    ).frame(
                                        width: .py_grid(10),
                                        height: .py_grid(10)
                                    ).padding(.py_grid(1))
                                    .onTapGesture {
                                        viewStore.send(.selectColor(color))
                                    }
                                }
                                Spacer(minLength: .py_grid(2))
                            }
                        }.padding()
                        

                        HDashedLine()
                        
                        HStack(alignment: .center, spacing: .zero) {
                            ProgressBarStyleView(
                                color: .constant(viewStore.chosenColor),
                                progressStyle:
                                    viewStore.binding(
                                        get: \.progressStyle,
                                        send: CreateTaskAction.selectStyle
                                    )
                            )
                            ProgressCircleStyleView(
                                color: .constant(viewStore.chosenColor),
                                progressStyle:
                                    viewStore.binding(
                                        get: \.progressStyle,
                                        send: CreateTaskAction.selectStyle
                                    )
                            )
                        }.padding()
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: .py_grid(50))
                    }
                    
                }.font(.preferred(.py_subhead()))
                .multilineTextAlignment(.center)
                
                                
                VStack(spacing: .zero) {
                    
                    if viewStore.isDiff {
                        ZStack(alignment: .leading) {
                            PLabel(attributedText: .constant(viewStore.diff))
                                .fixedSize()
                                .frame(maxWidth: .infinity)
                                .padding()
                            Button(action: {
                                viewStore.send(.reset)
                            }) {
                                Image(systemName: "xmark")
                            }.buttonStyle(RoundedButtonStyle())
                            .padding()
                        }.transition(.opacity)
                    }
                    
                    Button(
                        action: {
                            viewStore.send(.startButtonTapped)
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text(.startLabel, bundle: .tasks)
                        }
                    ).buttonStyle(
                        CreateButtonStyle(
                            isValid: viewStore.isValid,
                            color: viewStore.chosenColor
                        )
                    ).disabled(!viewStore.isValid)
                    .padding()
                    
                    
                }.frame(maxWidth: .infinity)
                .background(
                    VisualEffectBlur(blurStyle: .light)
                        .cornerRadius(.py_grid(8), corners: [.topLeft, .topRight])
                        .edgesIgnoringSafeArea(.vertical)
                )
                
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .alert(
                store.scope(state: \.alert),
                dismiss: .alertDismissed
            )
        }
    }
}

struct ProgressBarStyleView: View {
    @Binding var color: Color
    @Binding var progressStyle: ProgressStyle
    var body: some View {
        VStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: .py_grid(2))
                .fill(Color(white: 0.95))
                .frame(width: .py_grid(20), height: .py_grid(1))
            
            RoundedRectangle(cornerRadius: .py_grid(2))
                .fill(Color(white: 0.95))
                .frame(
                    width: .py_grid(15),
                    height: .py_grid(1))
            
            ProgressBar(
                color: progressStyle == .bar ? color: .gray,
                labelHidden: true,
                progress: .constant(0.2)
            ).frame(width: .py_grid(30))
            
        }.padding(.horizontal, .py_grid(2))
        .frame(height: .py_grid(15))
        .background(
            RoundedRectangle(
                cornerRadius: .py_grid(4),
                style: .continuous
            ).stroke(Color.white)
        ).frame(maxWidth: .infinity)
        .onTapGesture {
            progressStyle.toggle()
        }
    }
}

struct ProgressCircleStyleView: View {
    
    @Binding var color: Color
    @Binding var progressStyle: ProgressStyle
    
    var body: some View {
        HStack {
            
            ProgressCircle(
                color: progressStyle == .circle ? color: .gray,
                labelHidden: true,
                progress: .constant(0.4)
            ).frame(
                width: .py_grid(10),
                height: .py_grid(10)
            )
            
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .py_grid(2))
                    .fill(Color(white: 0.95))
                    .frame(width: .py_grid(20), height: .py_grid(1))
                RoundedRectangle(cornerRadius: .py_grid(2))
                    .fill(Color(white: 0.95))
                    .frame(width: .py_grid(15), height: .py_grid(1))
            }
            
        }.padding(.horizontal, .py_grid(2))
        .frame(height: .py_grid(15))
        .background(
            RoundedRectangle(
                cornerRadius: .py_grid(4),
                style: .continuous
            ).stroke(Color.white)
        ).frame(maxWidth: .infinity)
        .onTapGesture {
            progressStyle.toggle()
        }
    }
}

public enum DateControlAction: Equatable {
    case increment(Calendar.Component)
    case newDate(Date)
}

public let dateControlReducer =
    Reducer<Date, DateControlAction, Calendar> { date, action, calendar in
        switch action {
        case let .increment(component):
            return calendar
                .date(byAdding: component, value: 1, to: date)
                .flatMap(DateControlAction.newDate)
                .map(Effect.init(value:)) ?? .none
        case let .newDate(newDate):
            //date = newDate
            return .none
        }
    }

public struct DateControlView: View {
    
    let store: Store<Date, DateControlAction>
    
    public init(store: Store<Date, DateControlAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(
                state: dateFormatter().string(from:)
        )) { viewStore in
            VStack(spacing: .py_grid(4)) {
                                
                Text(viewStore.state)
                    .font(Font.preferred(
                        UIFont.py_title2(size: .py_grid(5))
                    ).smallCaps())
                    .frame(height: .py_grid(12))
                    .padding(.horizontal, .py_grid(10))
                    .background(
                        RoundedRectangle(cornerRadius: .py_grid(4))
                            .stroke(Color(white: 0.99))
                    )
                
                HStack {
                    Button(action: {
                        viewStore.send(.increment(.hour))
                    }) {
                        VStack(spacing: .py_grid(2)) {
                            Image(systemName: "plus")
                            Text(.hourLabel, bundle: .tasks)
                        }
                    }.buttonStyle(AddButtonStyle())
                    Button(action: {
                        viewStore.send(.increment(.day))
                    }) {
                        VStack(spacing: .py_grid(2)) {
                            Image(systemName: "plus")
                            Text(.dayLabel, bundle: .tasks)
                        }
                    }.buttonStyle(AddButtonStyle())
                    Button(action: {
                        viewStore.send(.increment(.month))
                    }) {
                        VStack(spacing: .py_grid(2)) {
                            Image(systemName: "plus")
                            Text(.monthLabel, bundle: .tasks)
                        }
                    }.buttonStyle(AddButtonStyle())
                    Button(action: {
                        viewStore.send(.increment(.year))
                    }) {
                        VStack(spacing: .py_grid(2)) {
                            Image(systemName: "plus")
                            Text(.yearLabel, bundle: .tasks)
                        }
                    }.buttonStyle(AddButtonStyle())
                }
                
            }
        }.environment(\.locale, Locale(identifier: "de"))
    }
}


private class TasksClass {}
extension Bundle {
    public static var tasks: Bundle {
        Bundle(for: TasksClass.self)
    }
}

import Combine
struct CreateTaskView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateTaskView(store: Store(
                initialState: CreateTaskState(
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(3600),
                    diff: .init(year: 1, month: 1, day: 1, hour: 1, minute: 1)
                ),
                reducer: createTaskReducer,
                environment: CreateTaskEnvironment(
                    uuid: UUID.init,
                    date: Date.init,
                    calendar: .current,
                    timeClient: TimeClient(
                        taskProgress: { request in
                            Just(
                                TimeResponse(
                                    progress: 0.3,
                                    result: TimeResult(
                                        year: Int.random(in: 1...10),
                                        month:
                                            request.calendar
                                            .dateComponents([.month],
                                                            from: request.startAt,
                                                            to: request.endAt).month!,
                                        day: Int.random(in: 1...10),
                                        hour: 1,
                                        minute: 1
                                    )
                                )
                            ).eraseToAnyPublisher()
                        }
                    ),
                    taskClient: .init(create: { _ in
                        Fail(error: .custom("an error "))
                            .eraseToAnyPublisher()
                    }
                    ),
                    managedContext: .init(concurrencyType: .privateQueueConcurrencyType),
                    notificationClient: .empty
                )
            ))
            
            CreateTaskView(store: Store(
                initialState: CreateTaskState(
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(3600)
                ),
                reducer: createTaskReducer,
                environment: CreateTaskEnvironment(
                    uuid: UUID.init,
                    date: Date.init,
                    calendar: .current,
                    timeClient: TimeClient(
                        taskProgress: { request in
                            Just(
                                TimeResponse(
                                    progress: 0.3,
                                    result: .zero
                                )
                            ).eraseToAnyPublisher()
                        }
                    ),
                    taskClient: .init(create: { _ in
                        Fail(error: .custom("an error "))
                            .eraseToAnyPublisher()
                    }
                    ),
                    managedContext: .init(concurrencyType: .privateQueueConcurrencyType),
                    notificationClient: .empty
                )
            )).preferredColorScheme(.dark)
           
        }
    }
}
