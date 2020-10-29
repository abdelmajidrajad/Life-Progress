import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import TaskClient
import CoreData

public struct TasksState: Equatable {
    var tasks: IdentifiedArrayOf<TaskState>
    var actionSheet: ActionSheetState<TasksAction>?
    public init(
        tasks: IdentifiedArrayOf<TaskState> = [],
        actionSheet: ActionSheetState<TasksAction>? = nil
    ) {
        self.tasks = tasks
        self.actionSheet = actionSheet
    }
}



public enum TasksAction: Equatable {
    case onAppear    
    case response(Result<TaskResponse, TaskFailure>)
    case ellipseButtonTapped(taskId: UUID)
    case actionSheetDismissed
    case addMore([Calendar.Component: Int], taskId: UUID)
    case completeTask(id: UUID)
    case deleteTask(id: UUID)
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
                
                state.actionSheet = ActionSheetState(
                    title: LocalizedStringKey(task.title),
                    buttons: [                        
                        .default("+\(valueFormatter().string(for: value) ?? "") \(key)", send: .addMore(item ?? [:], taskId: taskId)),
                        .default("Completed", send: .completeTask(id: taskId)),
                        .destructive("Delete", send: .deleteTask(id: taskId)),
                        .cancel(send: .actionSheetDismissed)
                    ]
                )
                return .none
            case .cell:
                return .none
            case .actionSheetDismissed:
                state.actionSheet = nil
                return .none
            case .addMore:
                return Effect(value: .actionSheetDismissed)
            case let .completeTask(id: taskId):
                return Effect(value: .actionSheetDismissed)
            case let .deleteTask(id: id):
                return Effect(value: .actionSheetDismissed)
            case .response(.success(.tasks(let tasks))):
                state.tasks = IdentifiedArray(tasks.map { TaskState(task: $0) } )
                return .none
            case .response(.success(.success)):
                return .none
            case .response(.failure):
                return .none                
            }
        },
        taskReducer.forEach(
            state: \.tasks,
            action: /TasksAction.cell(id:action:),
            environment: \.task
        )
    )


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

public struct TasksView: View {
    let store: Store<TasksState, TasksAction>
    public init(
        store: Store<TasksState, TasksAction>
    ) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                ForEachStore(
                    store.scope(
                        state: \.tasks,
                        action: TasksAction.cell(id:action:)),
                    content: { store in
                        WithViewStore(store) { vs in
                            ProgressTaskView(store: store) {
                                viewStore.send(
                                    .ellipseButtonTapped(
                                        taskId: vs.id
                                    )
                                )
                            }.padding(.vertical, .py_grid(1))
                        }
                    }
                )
            }.onAppear {
                viewStore.send(.onAppear)
            }
        }.actionSheet(
            store.scope(state: \.actionSheet),
            dismiss: .actionSheetDismissed
        )
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TasksView(store: Store<TasksState, TasksAction>(
                initialState: TasksState(
                    tasks: [
//                        TaskState(task: .readBook, color: .red),
//                        TaskState(task: .writeBook, color: .gray),
//                        TaskState(task: .readBook, color: .pink),
//                        TaskState(task: .writeBook, color: .red),
//                        TaskState(task: .writeBook, color: .blue)
                    ]
                ),
                reducer: tasksReducer,
                environment: TasksEnvironment(
                    date: Date.init,
                    calendar: .current,
                    managedContext: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType),
                    timeClient: .progress,
                    taskClient: TaskClient(tasks: { _ in
                        Just(TaskResponse.tasks([.readBook, .writeBook]))
                            .setFailureType(to: TaskFailure.self)
                            .eraseToAnyPublisher()
                    })
                )
            ))
            //.preferredColorScheme(.dark)            
        }
    }
}

import Combine
extension TimeClient {
    static var progress: TimeClient {
        TimeClient(taskProgress: { request in
            Just(
                TimeResponse(
                    progress: ((Int.random(in: 1...10) % 2) != 0) ? 0: 0.5,
                    result: TimeResult(
                        //year: 2,
                        //month: 1,
                        day: 7,
                        hour: 12,
                        minute: 44
                    )
                )
            ).eraseToAnyPublisher()
        })
    }
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
