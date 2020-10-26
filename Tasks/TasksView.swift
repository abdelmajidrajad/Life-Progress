import SwiftUI
import Core
import ComposableArchitecture
import TimeClient

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
    case ellipseButtonTapped(taskId: UUID)
    case actionSheetDismissed
    case cell(id: UUID, action: TaskAction)
}

struct TasksEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let timeClient: TimeClient
}

let tasksReducer =
    Reducer<TasksState, TasksAction, TasksEnvironment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .onAppear:
                return .none
            case let .ellipseButtonTapped(taskId: taskId):
                let task = state.tasks[id: taskId]!.task
                
                state.actionSheet = ActionSheetState(
                    title: LocalizedStringKey(task.title),
                    buttons: [
                        .default("+2 hours", send: .actionSheetDismissed),
                        .default("Send More days", send: .actionSheetDismissed),
                        .default("Completed", send: .actionSheetDismissed),
                        .destructive("DELETE", send: .actionSheetDismissed),
                        .cancel(send: .actionSheetDismissed)
                    ]
                )
                return .none
            case .cell:
                return .none
            case .actionSheetDismissed:
                state.actionSheet = nil
                return .none
            }
        },
        taskReducer.forEach(
            state: \.tasks,
            action: /TasksAction.cell(id:action:),
            environment: \.task
        )
    )

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
                                    .ellipseButtonTapped(taskId: vs.id)
                                )
                            }
                        }
                    }
                )
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
                        TaskState(task: .readBook, color: .red),
                        TaskState(task: .writeBook, color: .gray)
                    ]
                ),
                reducer: tasksReducer,
                environment: TasksEnvironment(
                    date: Date.init,
                    calendar: .current,
                    timeClient: .progress
                )
            ))            
        }
    }
}

import Combine
extension TimeClient {
    static var progress: TimeClient {
        TimeClient(taskProgress: { request in
            Just(
                TimeResponse(
                    progress: 0.3,
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
