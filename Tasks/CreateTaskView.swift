import SwiftUI
import Core
import TimeClient
import Validated
import TaskClient

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
    public var validationError: String?
    public var startDate: Date
    public var endDate: Date
    public var chosenColor: Color
    public var progressStyle: ProgressStyle
    public var diff: TimeResult
    public var alert: AlertState<CreateTaskAction>?
    public var isRequestSucceed: Bool = false
    public init(
        taskTitle: String = "",
        validationError: String? = nil,
        startDate: Date = Date(),
        endDate: Date = Date(),
        chosenColor: Color = Color(.endBlueLightColor),
        progressStyle: ProgressStyle = .bar,
        diff: TimeResult = .zero,
        alert: AlertState<CreateTaskAction>? = nil,
        isRequestSucceed: Bool = false
    ) {
        self.title = taskTitle
        self.validationError = validationError
        self.startDate = startDate
        self.endDate = endDate
        self.chosenColor = chosenColor
        self.progressStyle = progressStyle
        self.diff = diff
        self.alert = alert
        self.isRequestSucceed = isRequestSucceed
    }
}

public enum CreateTaskAction: Equatable {
    case onAppear
    case response(Result<TaskResponse, TaskFailure>)
    case startButtonTapped
    case selectStyle(ProgressStyle)
    case diff(TimeResult)
    case titleChanged(String)
    case validation(Validated<String, String>)
    case selectColor(Color)
    case reset
    case alertDismissed
    case endDate(DateControlAction)
    case startDate(DateControlAction)
    case cancelButtonTapped
}

import CoreData
public struct CreateTaskEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let timeClient: TimeClient
    let managedContext: NSManagedObjectContext
    let taskClient: TaskClient
    public init(
        date: @escaping () -> Date,
        calendar: Calendar,
        timeClient: TimeClient,
        taskClient: TaskClient,
        managedContext: NSManagedObjectContext
    ) {
        self.date = date
        self.calendar = calendar
        self.timeClient = timeClient
        self.taskClient = taskClient
        self.managedContext = managedContext
    }
}


import ComposableArchitecture
public let createTaskReducer = Reducer<CreateTaskState, CreateTaskAction, CreateTaskEnvironment>.combine(
    dateControlReducer.pullback(
        state: \.startDate,
        action: /CreateTaskAction.startDate,
        environment: { $0.calendar }
    ), dateControlReducer.pullback(
        state: \.endDate,
        action: /CreateTaskAction.endDate,
        environment: { $0.calendar }
    ),
    Reducer { state, action, environment in
        switch action {
        case .startButtonTapped:
            return environment.taskClient.create(
                TaskRequest(
                    viewContext: environment.managedContext,
                    task: ProgressTask(
                        title: state.title,
                        startDate: state.startDate,
                        endDate: state.endDate,
                        creationDate: environment.date(),
                        color: state.chosenColor.uiColor(),
                        style: state.progressStyle == .bar ? .bar: .circle
                    )
                )
            ).catchToEffect()
             .map(CreateTaskAction.response)
        case let .selectStyle(style):
            state.progressStyle = style
            return .none
        case .reset:
            state.startDate = environment.date()
            state.endDate = environment.date()
            state.diff = .zero
            return .none
        case let .titleChanged(title):
            state.title = title
            return Effect(value:
                    .validation(validate(title: title))
                    )
        case let .selectColor(color):
            state.chosenColor = color
            return .none
        case let .startDate(.newDate(date)):
            if date <= state.endDate {
                state.startDate = date
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
        case let .endDate(.newDate(date)):
            state.endDate = date
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
            state.startDate = environment.date()
            state.endDate = environment.date()
            return Effect(value: .titleChanged(""))
        case .validation(.valid):
            state.validationError = nil
            return .none
        case let .validation(.invalid(errors)):
            state.validationError = errors.first
            return .none
        case .startDate, .endDate:
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
        }
    }
)


extension CreateTaskState {
    var view: CreateTaskView.ViewState {
        .init(
            title: title,
            startDate: startDate,
            endDate: endDate,
            chosenColor: chosenColor,
            progressStyle: progressStyle,
            diff: diff.string(taskCellStyle, style: .long),
            isDiff: diff != .zero,
            isValid: validationError == nil && diff != .zero
        )
    }
}


public struct CreateTaskView: View {
    public struct ViewState: Equatable {
        public var title: String
        public var startDate: Date
        public var endDate: Date
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
                    
                    VStack(spacing: .zero) {                       
                        ZStack(alignment: .leading) {
                            Button(action: {
                                self.presentationMode
                                    .wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                            }.buttonStyle(CloseButtonCircleStyle())
                            .zIndex(1)
                            
                            Text("Create A New Task".uppercased())
                                .font(.preferred(.py_title3()))
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .bottom
                                )
                        }.padding()                        
                    }
                
                
                    ScrollView(.vertical) {
                        
                        TextField(String.taskTitle, text: viewStore.binding(
                            get: \.title,
                            send: CreateTaskAction.titleChanged
                        ))
                        .font(Font.preferred(.py_title3()).bold())
                        .padding()
                        
                        TitleLined(.startDate)
                        
                        DateControlView(
                            store: store.scope(
                                state: \.startDate,
                                action: CreateTaskAction.startDate
                            ))
                        
                        TitleLined(.endDate)
                        
                        DateControlView(
                            store: store.scope(
                                state: \.endDate,
                                action: CreateTaskAction.endDate
                            ))
                        
                        TitleLined(.progressColor)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Spacer(minLength: .py_grid(2))
                                
                                if #available(iOS 14.0, *) {
                                    ColorPicker("",
                                                selection:
                                                    viewStore.binding(
                                                        get: \.chosenColor,
                                                        send: CreateTaskAction.selectColor
                                                    )
                                    )
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
                                                    : 0.35)
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
                        }
                        
                        TitleLined(.styleLabel)
                        
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
                        }.padding(.horizontal)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: .py_grid(50))
                    
                    }.padding(.top, .py_grid(20))
                    
                }.font(.preferred(.py_subhead()))
                .multilineTextAlignment(.center)
                                
                VStack(spacing: .py_grid(4)) {
                    
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
                        }
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
                    ).padding(.bottom)
                    .disabled(!viewStore.isValid)
                    
                }.frame(maxWidth: .infinity)
                .padding(.py_grid(1))
                .background(
                    VisualEffectBlur(blurStyle: .extraLight)
                )
                
            }
            .edgesIgnoringSafeArea(.vertical)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .alert(
                store.scope(
                    state: \.alert), dismiss: .alertDismissed
            )
        }
    }
}


struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.py_grid(1))
            .font(.preferred(UIFont.py_caption2().monospaced.bolded))
            .foregroundColor(
                configuration.isPressed
                ? Color.white
                : Color(.lightGray)
            )
            .multilineTextAlignment(.center)
            .frame(width: .py_grid(14), height: .py_grid(14))
            .background(
                RoundedRectangle(cornerRadius: .py_grid(3), style: .continuous)
                    .stroke(
                        configuration.isPressed
                            ? Color.blue
                            : Color.white.opacity(0.2)
                    )
            ).scaleEffect(configuration.isPressed ? 1.1: 1)
            .animation(.linear(duration: 0.2))
        
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(white: 0.5))
            .padding(.py_grid(2))
            .background(
                Circle()
                    .fill(Color(white: 0.98))
            )
        
    }
}

struct CreateButtonStyle: ButtonStyle {
    var isValid: Bool = false
    let color: Color
    public init(
        isValid: Bool = false,
        color: Color
    ) {
        self.isValid = isValid
        self.color = color
    }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(Font.preferred(.py_title2()).bold().smallCaps())
            .padding()
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: .py_grid(4))
                    .fill(color.opacity(isValid ? 1: 0.5))
            )
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
        }
    }
}

struct TitleLined: View {
    let title: LocalizedStringKey
    init(_ title: LocalizedStringKey) {
        self.title = title
    }
    var body: some View {
        VStack(alignment: .leading, spacing: .py_grid(1)) {
            Text(title, bundle: .tasks)
                .font(Font.preferred(.py_subhead()).smallCaps())
                .foregroundColor(.gray)
                .padding(.leading)
            HDashedLine()
        }
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
                    diff: .init(year: 1, month: 1, day: 1, hour: 1, minute: 1)
                ),
                reducer: createTaskReducer,
                environment: CreateTaskEnvironment(
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
                    managedContext: .init(concurrencyType: .privateQueueConcurrencyType)
                )
            ))
            
            CreateTaskView(store: Store(
                initialState: CreateTaskState(
                    diff: .init(year: 1, month: 1, day: 1, hour: 1, minute: 1)
                ),
                reducer: createTaskReducer,
                environment: CreateTaskEnvironment(
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
                    managedContext: .init(concurrencyType: .privateQueueConcurrencyType)
                )
            ))
            .preferredColorScheme(.dark)
        }
    }
}
