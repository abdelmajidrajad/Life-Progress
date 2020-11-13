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
    //var actionSheet: ActionSheetState<TasksAction>?
    var createTask: CreateTaskState?
    var filter: Filter
    public init(
        tasks: IdentifiedArrayOf<TaskState> = [],
        //actionSheet: ActionSheetState<TasksAction>? = nil,
        createTask: CreateTaskState? = nil,
        filter: Filter = .active
    ) {
        self.tasks = tasks
       // self.actionSheet = actionSheet
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
    case ellipseButtonTapped(taskId: UUID)
    case plusButtonTapped
    case actionSheetDismissed
    case viewDismissed
    case addMore([Calendar.Component: Int], taskId: UUID)
    case completeTask(id: UUID)
    case deleteTask(id: UUID)
    case createTask(CreateTaskAction)
    case cell(id: UUID, action: TaskAction)
}

public struct TasksEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let managedContext: NSManagedObjectContext
    let timeClient: TimeClient
    let taskClient: TaskClient
    public init(
        date: @escaping () -> Date,
        calendar: Calendar,
        managedContext: NSManagedObjectContext,
        timeClient: TimeClient,
        taskClient: TaskClient
    ) {
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
            case let .ellipseButtonTapped(taskId: taskId):
                
                let task = state.tasks[id: taskId]!.task

                let item: [Calendar.Component: Int]? = task
                    |> dateComponents(environment.calendar)
                    >>> suggestedComponent
                
                let value = Double(item?.first?.value ?? .zero) / 4.0
                let key = item?.first?.key.string ?? ""
                
//                state.actionSheet = ActionSheetState(
//                    title: LocalizedStringKey(task.title),
//                    buttons: [
//                        .default("+\(valueFormatter().string(for: value) ?? "") \(key)", send: .addMore(item ?? [:], taskId: taskId)),
//                        .default("Completed", send: .completeTask(id: taskId)),
//                        .destructive("Delete", send: .deleteTask(id: taskId)),
//                        .cancel(send: .actionSheetDismissed)
//                    ]
//                )
                return .none
            case let .createTask(.response(.success(.created(task)))):
                state.tasks.append(
                    TaskState(task: task)
                )
                return .none
            case let .createTask(.response(.success(.updated(task)))):
                state.tasks[id: task.id] = TaskState(task: task)
                return .none
            case .createTask:
                return .none
            case .actionSheetDismissed:
                //state.actionSheet = nil
                return .none
            case .addMore:
                return Effect(value: .actionSheetDismissed)
            case let .completeTask(id: taskId):
                let updatedTask = state.tasks[id: taskId]!.task
                    |> (prop(\.endDate)) { _ in environment.date() }
                return Effect.concatenate(
                    environment
                        .taskClient
                        .update(
                            TaskRequest(
                                viewContext: environment.managedContext,
                                task: updatedTask
                            )
                        )
                        .catchToEffect()
                        .map(TasksAction.response),
                    Effect(value: .actionSheetDismissed)
                )
            case let .deleteTask(id: id):
                return .concatenate(
                    environment.taskClient
                        .delete(
                            TaskRequest(
                                viewContext: environment.managedContext,
                                task: state.tasks[id: id]!.task
                            )
                        ).catchToEffect()
                        .map(TasksAction.response),
                    Effect(value: .actionSheetDismissed)
                )
            case let .response(.success(.tasks(tasks))):
                state.tasks = IdentifiedArray(
                    tasks.map(TaskState.init(task:))
                )
                return .none
            case let .response(.failure(error)):
//                state.actionSheet = ActionSheetState(
//                    title: LocalizedStringKey(error.errorDescription),
//                    buttons: [
//                        .cancel(send: .actionSheetDismissed)
//                    ]
//                )
                return .none
            case let .response(.success(.deleted(id: taskId))):
                state.tasks.removeAll { $0.id == taskId }
                return .none
            case let .response(.success(.updated(task))):
                state.tasks[id: task.id]?.task = task
                return .none
            case .response:
                return .none
            case .plusButtonTapped:
                state.createTask = CreateTaskState()
                return .none
            case .viewDismissed:
                state.createTask = nil
                return .none
            case .onChange:
                return .concatenate(
                    state.tasks
                        .map {
                            Effect(value:
                            .cell(id: $0.id, action: .onAppear))
                        }
                )
            case let .filterPicked(filter):
                state.filter = filter
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
                case .onAppear,
                     .response,
                     .ellipseButtonTapped,
                     .actionSheetDismissed:
                    return .none
                case .deleteTapped:
                    state.tasks.remove(id: id)
                    return .none
                case .startAgainTapped:
                    state.tasks[id: id]?.status = .active
                    return .none
                case .startNowTapped:
                    state.tasks[id: id]?.status = .active
                    return .none
                case .duplicateTapped:
                    if let duplicateTask = state.tasks[id: id] {
                        state.tasks.append(duplicateTask)
                    }
                    return .none
                case .completeTapped:
                    state.tasks[id: id]?.status = .completed
                    return .none
                case .startTomorrowTapped:
                    state.tasks[id: id]?.status = .pending
                    return .none
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

struct CornerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(4),
                    style: .continuous
                ).stroke(Color.white)
            )
    }
}


class SelectedCornerButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(4),
                    style: .continuous
                ).stroke(isSelected
                            ? Color(.label)
                            : Color(.systemBackground)
                )
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
                        content: { store in
                            ProgressTaskView(store: store)
//                            WithViewStore(store) { vs in
//                                ProgressTaskView(store: store) {
//                                    viewStore.send(
//                                        .ellipseButtonTapped(
//                                            taskId: vs.id
//                                        )
//                                    )
//                                }.padding(.vertical, .py_grid(1))
//                            }
                        }
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
//        .actionSheet(
//            store.scope(state: \.actionSheet),
//            dismiss: .actionSheetDismissed
//        )
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
                    progress: ((Int.random(in: 1...10) % 2) != 0) ? 0: 0,
                    result: TimeResult(
                        //year: 2,
                        //month: 1,
                        //day: 7,
                        hour: 12
                        //minute: 44
                    )
                )
            ).eraseToAnyPublisher()
        })
    }
}

extension TaskClient {
    static var createBook: TaskClient = TaskClient(
        create: { _ in
            Just(
                .created(.writeBook2)
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


let dateComponents: (Calendar) -> (ProgressTask) -> DateComponents = { calendar in
    {
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
