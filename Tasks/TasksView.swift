import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import TaskClient
import CoreData

public enum Filter: LocalizedStringKey, CaseIterable, Hashable {
    case pending = "Pending"
    case active = "Active"
    case completed = "Completed"
}


public struct TasksState: Equatable {
    var tasks: IdentifiedArrayOf<TaskState>
    var createTask: CreateTaskState?
    var filter: Filter
    public init(
        tasks: IdentifiedArrayOf<TaskState> = [],
        createTask: CreateTaskState? = nil,
        filter: Filter = .active
    ) {
        self.tasks = tasks
        self.createTask = createTask
        self.filter = filter
    }
    
    var filteredTasks: IdentifiedArrayOf<TaskState> {
        switch filter {
        case .active:
            return tasks.filter { $0.status == .active }
        case .pending:
            return tasks.filter { $0.status == .pending }
        case .completed:
            return tasks.filter { $0.status == .completed }
        }
    }
    
}

public enum TasksAction: Equatable {
    case onAppear
    case onChange
    case filterPicked(Filter)
    case response(Result<TaskResponse, TaskFailure>)
    case plusButtonTapped
    case viewDismissed
    case duplicateTask(CreateTaskState)
    case createTask(CreateTaskAction)
    case cell(id: UUID, action: TaskAction)
}

public struct TasksEnvironment {
    let uuid: () -> UUID
    let date: () -> Date
    let calendar: Calendar
    let managedContext: NSManagedObjectContext
    let timeClient: TimeClient
    let taskClient: TaskClient
    public init(
        uuid: @escaping () -> UUID,
        date: @escaping () -> Date,
        calendar: Calendar,
        managedContext: NSManagedObjectContext,
        timeClient: TimeClient,
        taskClient: TaskClient
    ) {
        self.uuid = uuid
        self.date = date
        self.calendar = calendar
        self.managedContext = managedContext
        self.timeClient = timeClient
        self.taskClient = taskClient
    }
}

public let tasksReducer =
    Reducer<TasksState, TasksAction, TasksEnvironment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .onAppear:
                return environment.taskClient
                    .tasks(environment.managedContext)
                    .catchToEffect()
                    .map(TasksAction.response)
            case let .createTask(.response(.success(.created(task)))):
                state.tasks.append(TaskState(task: task))
                return .none
            case let .createTask(.response(.success(.updated(task)))):
                state.tasks[id: task.id] = TaskState(task: task)
                return .none
            case .createTask:
                return .none
            case let .duplicateTask(task):
                state.createTask = task
                return .none
            case let .response(.success(.tasks(tasks))):
                state.tasks = IdentifiedArray(
                    tasks.map(TaskState.init(task:))
                )
                return .none
            case let .response(.failure(error)):                
                return .none
            case let .response(.success(.deleted(id: taskId))):
                state.tasks.remove(id: taskId)
                return .none
            case let .response(.success(.updated(task))):
                state.tasks[id: task.id]?.task = task
                return Effect(value: .cell(id: task.id, action: .onAppear))
            case .plusButtonTapped:
                state.createTask = CreateTaskState(
                    startDate: environment.date(),
                    endDate: environment.date()
                )
                return .none
            case .viewDismissed:
                state.createTask = nil
                return .none
            case .onChange:
                return .concatenate(
                    state.tasks
                        .map {
                            Effect(value: .cell(id: $0.id, action: .onAppear))
                        }
                )
            case let .filterPicked(filter):
                state.filter = filter
                return .none
            case let .response(.success(.created(task))):
                return .none
            case .cell:
                return .none
            }
        },
        taskReducer.forEach(
            state: \.tasks,
            action: /TasksAction.cell(id:action:),
            environment: \.task
        ),
        createTaskReducer
            .optional()
            .pullback(
                state: \.createTask,
                action: /TasksAction.createTask,
                environment: \.createTask
            )
).cellReducer



extension Calendar.Component {
    static var all: Set<Calendar.Component> {
        [.hour, .year, .day, .hour, .minute]
    }
}

extension Reducer where
    State == TasksState,
    Action == TasksAction,
    Environment == TasksEnvironment {
    var cellReducer: Self {
        Self { state, action, environment in
            let effects = self(&state, action, environment)
            switch action {
            case let .cell(id: id, action: action):
                switch action {
                case .deleteTapped:
                    
                    guard let taskState = state.tasks[id: id] else { fatalError() }
                    
                    return environment.taskClient
                        .delete(TaskRequest(
                            viewContext: environment.managedContext,
                            task: taskState.task
                        )).catchToEffect()
                        .map(TasksAction.response)
                        .eraseToEffect()
                case .startNowTapped:
                    
                    guard let taskState = state.tasks[id: id] else { fatalError() }
                    
                    let components = environment.calendar
                        .dateComponents(Calendar.Component.all,
                                        from: taskState.startDate,
                                        to: taskState.endDate
                        )
                    
                    let updatedTask = taskState.task
                        |> (prop(\.startDate)) { _ in environment.date() }
                        <> (prop(\.endDate)) { _ in
                            environment.calendar.date(byAdding: components, to: environment.date())!
                        }
                                                               
                    return environment
                         .taskClient
                         .update(
                            TaskRequest(
                                viewContext: environment.managedContext,
                                task: updatedTask
                            )
                        ).catchToEffect()
                         .map(TasksAction.response)
                case .duplicateTapped:
                    
                    guard let task = state.tasks[id: id] else { fatalError() }
                    
                    let components = environment.calendar
                        .dateComponents(Calendar.Component.all,
                                        from: task.startDate,
                                        to: task.endDate
                        )
                    
                    let duplicateTask = state.tasks[id: id]!.task
                        |> (prop(\.id)) { _ in environment.uuid() }
                        <> (prop(\.startDate)) { _ in environment.date() }
                        <> (prop(\.creationDate)) { _ in environment.date() }
                        <> (prop(\.endDate)) { _ in
                            environment.calendar.date(byAdding: components, to: environment.date())!
                        }
                
                    return environment
                        .timeClient
                        .taskProgress(
                            ProgressTaskRequest(
                                currentDate: environment.date(),
                                calendar: environment.calendar,
                                startAt: duplicateTask.startDate,
                                endAt: duplicateTask.endDate
                            )).map(\.result)
                              .map {
                                CreateTaskState(
                                    taskTitle: duplicateTask.title,
                                    startDate: duplicateTask.startDate,
                                    endDate: duplicateTask.endDate,
                                    chosenColor: Color(duplicateTask.color),
                                    progressStyle: .bar,
                                    diff: $0
                                )
                              }.map(TasksAction.duplicateTask)
                        .eraseToEffect()
                case .completeTapped:
                    
                    guard let taskState = state.tasks[id: id] else { fatalError() }
                    
                    let updatedTask = taskState.task
                        |> (prop(\.endDate)) { _ in environment.date() }
                    
                    return environment
                        .taskClient
                        .update(
                            TaskRequest(
                                viewContext: environment.managedContext,
                                task: updatedTask
                            )
                        ).catchToEffect()
                         .map(TasksAction.response)
                    
                case .startTomorrowTapped:
                    
                    guard let taskState = state.tasks[id: id] else { fatalError() }
                    guard let startDate = environment
                            .calendar
                            .date(byAdding: .day, value: 1, to: taskState.startDate) else { fatalError()}
                    guard let endDate = environment
                            .calendar
                            .date(byAdding: .day, value: 1, to: taskState.endDate) else {
                        fatalError()
                    }
                                                            
                    let updatedTask = taskState.task
                        |> (prop(\.startDate)) { _ in startDate }
                        <> (prop(\.endDate)) { _ in endDate }
                    
                    return environment
                        .taskClient
                        .update(
                            TaskRequest(
                                viewContext: environment.managedContext,
                                task: updatedTask
                            )
                        ).catchToEffect()
                         .map(TasksAction.response)
                default:
                    return effects
                }
            default:
                return effects
            }
        }
    }
}



extension TasksEnvironment {
    var createTask: CreateTaskEnvironment {
        CreateTaskEnvironment(
            date: date,
            calendar: calendar,
            timeClient: timeClient,
            taskClient: taskClient,
            managedContext: managedContext
        )
    }
}


let valueFormatter: () -> NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.roundingMode = .ceiling
    return formatter
}

extension TasksEnvironment {
    var task: TaskEnvironment {
        TaskEnvironment(
            date: date,
            calendar: calendar,
            taskProgress: timeClient.taskProgress
        )
    }
}

extension AnyTransition {
    static var topAndLeft: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .bottom),
            removal: .move(edge: .leading)
        ).animation(.linear)
    }
}


public struct TasksView: View {
    let store: Store<TasksState, TasksAction>
    public init(
        store: Store<TasksState, TasksAction>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(showsIndicators: false) {
                Section(header:
                            VStack {
                                
                                Text("Tasks")
                                    .font(Font
                                            .preferred(.py_title2())
                                            .bold()
                                    ).frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {                                    
                                    Button(action: {
                                        withAnimation {
                                            viewStore.send(.filterPicked(.completed))
                                        }
                                    }, label: {
                                        Image(systemName: "checkmark")
                                    }).padding(.vertical)
                                    .buttonStyle(
                                        SelectedCornerButtonStyle(
                                            isSelected: viewStore.filter == .completed
                                        )
                                    )
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewStore.send(.filterPicked(.pending))
                                        }
                                    }, label: {
                                        Image(systemName: "clock.fill")
                                    }).padding(.vertical)
                                    .buttonStyle(
                                        SelectedCornerButtonStyle(
                                            isSelected: viewStore.filter == .pending)
                                    )
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewStore.send(.filterPicked(.active))
                                        }
                                    }, label: {
                                        Image(systemName: "chart.bar.fill")
                                    }).padding(.vertical)
                                    .buttonStyle(
                                        SelectedCornerButtonStyle(
                                            isSelected: viewStore.filter == .active)
                                    )
                                    
                                    Spacer()
                                    HStack {
                                        Button(action: {
                                            viewStore.send(.plusButtonTapped)
                                        }, label: {
                                            Image(systemName: "plus")
                                        }).padding(.vertical)
                                        .buttonStyle(CornerButtonStyle())
                                    }
                                }
                }.padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .listRowInsets(.zero)
                ) {
                    ForEachStore(
                        store.scope(
                            state: \.filteredTasks,
                            action: TasksAction.cell(id:action:)),
                        content: ProgressTaskView.init(store:)
                    )
                }
            }.onAppear {
                viewStore.send(.onAppear)
            }.sheet(isPresented:
                        viewStore.binding(
                            get: { $0.createTask != nil },
                            send: TasksAction.viewDismissed
                        )) {
                IfLetStore(
                    store.scope(
                        state: \.createTask,
                        action: TasksAction.createTask),
                    then: CreateTaskView.init(store:)
                )
            }
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TasksView(store: Store<TasksState, TasksAction>(
                initialState: TasksState(
                    tasks: []
                    
                ),
                reducer: tasksReducer,
                environment: TasksEnvironment(
                    uuid: UUID.init,
                    date: Date.init,
                    calendar: .current,
                    managedContext: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType),
                    timeClient: .progress,
                    taskClient: .createBook
                )
            ))
                        
            TasksView(store: Store<TasksState, TasksAction>(
                initialState: TasksState(
                    tasks: []
                ),
                reducer: tasksReducer,
                environment: TasksEnvironment(
                    uuid: UUID.init,
                    date: Date.init,
                    calendar: .current,
                    managedContext: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType),
                    timeClient: .progress,
                    taskClient: .createBook
                )
            )).preferredColorScheme(.dark)
            
            
                                    
        }
    }
}

import Combine
extension TimeClient {
    static var progress: TimeClient {
        TimeClient(taskProgress: { request in
            Just(
                TimeResponse(
                    progress: 0.4,
                    result: TimeResult(
                        hour: 12,
                        minute: 30
                    )
                )
            ).eraseToAnyPublisher()
        })
        
        
    }
}

extension TaskClient {
    public static var createBook: TaskClient = TaskClient(
        create: { _ in
            Just(
                .created(.writeBook)
            ).setFailureType(to: TaskFailure.self)
            .eraseToAnyPublisher()
        },
        tasks: { _ in
            Just(
                .tasks([.writeBook2, .writeBook])
            ).setFailureType(to: TaskFailure.self)
            .eraseToAnyPublisher()
            
        })
}


let dateComponents: (Calendar) -> (ProgressTask) -> DateComponents = { calendar in {
        calendar.dateComponents(
            [.day, .hour, .minute, .month, .year],
            from: $0.startDate,
            to: $0.endDate
        )
    }
}


let suggestedComponent: (DateComponents) -> [Calendar.Component: Int]? = { components in    
    [Calendar.Component.year,
    .month,
    .day,
    .hour,
    .minute]
        .compactMap {
            [$0: components.value(for: $0) ?? .zero]
    }.filter {
        $0.values.first != .zero
    }.first
}


extension Calendar.Component {
    public var string: String {
        switch self {
        case .era:
            return "era"
        case .year:
            return "year"
        case .month:
            return "month"
        case .day:
            return "day"
        case .hour:
            return "hour"
        case .minute:
            return "minute"
        case .second:
            return "second"
        case .weekday:
            return "weekday"
        case .weekdayOrdinal:
            return "weekdayOrdinal"
        case .quarter:
            return "quarter"
        case .weekOfMonth:
            return "weekOfMonth"
        case .weekOfYear:
            return "weekOfYear"
        case .yearForWeekOfYear:
            return "yearForWeekOfYear"
        case .nanosecond:
            return "nanosecond"
        case .calendar:
            return "calendar"
        case .timeZone:
            return "timeZone"
        @unknown default:
            return "unknown"
        }
    }
    
    
}
