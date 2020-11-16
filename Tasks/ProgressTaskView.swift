import SwiftUI
import Core
import TimeClient
import Combine
import TaskClient


@dynamicMemberLookup
public struct TaskState: Equatable, Identifiable {
    
    public enum Status: Equatable {
        case completed, active, pending
    }
    
    public var id: UUID { task.id }    
    var task: ProgressTask
    var remainingTime: NSAttributedString
    var result: TimeResult
    var progress: Double
    var status: Status
    var isSelected: Bool
    var actionSheet: ActionSheetState<TaskAction>?
    public init(
        task: ProgressTask,
        remainingTime: NSAttributedString = .init(),
        progress: Double = .zero,
        result: TimeResult = .init(),
        status: Status = .active,
        isSelected: Bool = false,
        actionSheet: ActionSheetState<TaskAction>? = nil
    ) {
        self.task = task
        self.progress = progress
        self.remainingTime = remainingTime
        self.result = result
        self.isSelected = isSelected
        self.status = status
        self.actionSheet = actionSheet
    }
    public init(
        task: ProgressTask
    ) {
        self.task = task
        self.progress = .zero
        self.remainingTime = .init()
        self.result = .init()
        self.isSelected = false
        self.status = .active
        self.actionSheet = nil
    }
}

extension TaskState {
    public subscript<LocalState>(
        dynamicMember
            keyPath: KeyPath<ProgressTask, LocalState>)
    -> LocalState {
        self.task[keyPath: keyPath]
    }
}

public struct TaskEnvironment {
    let date: () -> Date
    let calendar: Calendar
    let taskProgress:
    (ProgressTaskRequest) -> AnyPublisher<TimeResponse, Never>
}

public enum TaskAction: Equatable {
    case onAppear
    case response(TimeResponse)
    case ellipseButtonTapped
    case actionSheetDismissed
    case deleteTapped
    case startNowTapped
    case duplicateTapped
    case completeTapped
    case startTomorrowTapped
}

import ComposableArchitecture
public let taskReducer =
    Reducer<TaskState, TaskAction, TaskEnvironment> {
        state, action, environment in
        switch action {
        case .onAppear:
            state.status =
                environment.date() >= state.task.endDate
                ? .completed
                : environment.date() < state.task.startDate
                ? .pending: .active
                
            return environment.taskProgress(
                ProgressTaskRequest(
                    currentDate: environment.date(),
                    calendar: environment.calendar,
                    startAt: state.task.startDate,
                    endAt: state.task.endDate
                )).map(TaskAction.response)
                .eraseToEffect()
        case let .response(response):
            state.result = response.result
            state.progress = response.progress
            return .none
        case .actionSheetDismissed:
            state.actionSheet = nil
            return .none
        case .deleteTapped:
            return .none
        case .ellipseButtonTapped:
            
            var actionButtons: [ActionSheetState<TaskAction>.Button] = []
            
            switch state.status {
            case .completed:
                actionButtons.append(contentsOf: [
                    .default("Start Again", send: .startNowTapped),
                    .default("Duplicate", send: .duplicateTapped)
                ])
            case .active:
                actionButtons.append(contentsOf: [
                    .default("Start Tomorrow", send: .startTomorrowTapped),
                    .default("End", send: .completeTapped),
                    .default("Duplicate", send: .duplicateTapped)
                ])
            case .pending:
                actionButtons.append(contentsOf: [
                    .default("Start Now", send: .startNowTapped),
                    .default("Duplicate", send: .duplicateTapped)
                ])
            }
            
            actionButtons.append(contentsOf: [
                .destructive("Delete", send: .deleteTapped),
                .cancel(send: .actionSheetDismissed)
            ])
                                    
            state.actionSheet = ActionSheetState(
                title: LocalizedStringKey(state.title),
                buttons: actionButtons
            )
            state.isSelected.toggle()
            return .none        
        case .startNowTapped:
            return .none
        case .duplicateTapped:
            return .none
        case .completeTapped:
            return .none
        case .startTomorrowTapped:
            return .none
        }
    }


extension TaskState {
    var view: ProgressTaskView.ViewState {
        .init(
            title: task.title,
            remaining: result.string(
                taskCellStyle, style: .long),
            progress: NSNumber(value: progress),            
            color: Color(task.color),
            isCircle: task.style == .circle,
            status: status,
            startDate: pendingDateFormatter.string(from: task.startDate),
            endDate: pendingDateFormatter.string(from: task.endDate)
        )
    }
}

var pendingDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm a EEEE, d MMM YYYY"
    return formatter
}


struct ProgressTaskView: View {
    
    struct ViewState: Equatable {
        let title: String
        let remaining: NSAttributedString
        let progress: NSNumber
        let color: Color
        let isCircle: Bool
        let status: TaskState.Status
        let startDate: String
        let endDate: String
    }
    
    let store: Store<TaskState, TaskAction>
    
    init(store: Store<TaskState, TaskAction>) {
        self.store = store
    }
    
    var body: some View {
        
        WithViewStore(self.store.scope(state: \.view)) { viewStore in
            VStack {
                if viewStore.isCircle {
                    HStack {
                        
                        ProgressCircle(
                            color: viewStore.color,
                            lineWidth: .py_grid(1),
                            labelHidden: false,
                            progress: .constant(viewStore.progress)
                        ).frame(width: .py_grid(18))
                        
                        VStack(alignment: .leading, spacing: .py_grid(2)) {
                            Text(viewStore.title)
                                .font(.preferred(.py_body()))
                                .frame(
                                    maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                                    alignment: .leading
                                ).padding(.trailing, .py_grid(4))
                                .lineLimit(2)
                            
                            switch viewStore.status {
                            case .active:
                                PLabel(attributedText: .constant(viewStore.remaining))
                                    .fixedSize()
                            case .completed:
                                HStack {
                                    Text(viewStore.endDate)
                                        .font(.preferred(.py_footnote()))
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(.systemGreen))
                                }
                            case .pending:
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(
                                            viewStore.color.opacity(0.5)
                                        )
                                    Text(viewStore.startDate)
                                        .font(.preferred(.py_footnote()))
                                }
                            }
                        }
                    }
                    
                } else {
                    VStack(alignment: .leading, spacing: .py_grid(2)) {
                        
                        VStack(alignment: .leading, spacing: .py_grid(2)) {
                            Text(viewStore.title)
                                .font(.preferred(.py_body()))
                                .frame(
                                    maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                                    alignment: .leading
                                ).padding(.trailing, .py_grid(5))
                                .lineLimit(2)
                            
                            switch viewStore.status {
                            case .active:
                                PLabel(attributedText: .constant(viewStore.remaining))
                                    .fixedSize()
                            case .completed:
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(.systemGreen))
                                    Text(viewStore.endDate)
                                        .font(.preferred(.py_footnote()))
                                }
                            case .pending:
                                HStack {
                                    Image(systemName: "clock.fill")
                                    Text(viewStore.startDate)
                                        .font(.preferred(.py_footnote()))
                                }
                            }
                            
                        }
                        
                        ProgressBar(
                            color: viewStore.color,
                            lineWidth: .py_grid(1),
                            labelHidden: true,
                            progress: .constant(viewStore.progress)
                        )
                        
                    }
                }
            }.padding()
            .background(
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(
                        cornerRadius: .py_grid(4),
                        style: .continuous
                    ).stroke(Color(white: 0.95))
                    
                    Button(action: {
                        viewStore.send(.ellipseButtonTapped)
                    },
                           label: {
                            Image(systemName: "ellipsis")
                                .font(.headline)
                                .accentColor(.gray)
                           }
                    ).padding()
                }
            ).padding(.horizontal)
            .transition(.topAndLeft)
            .onAppear {
                viewStore.send(.onAppear)
            }.actionSheet(
                store.scope(state: \.actionSheet),
                dismiss: .actionSheetDismissed
            )
        }
    }
}

struct ProgressTaskView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressTaskView(
                store:
                    Store(
                        initialState: TaskState(
                            task: .writeBook,
                            status: .active
                        ),
                        reducer: taskReducer,
                        environment: TaskEnvironment(
                            date: Date.init,
                            calendar: .current,
                            taskProgress: { _ in
                                Just(
                                    TimeResponse(
                                        progress: 0.4,
                                        result: TimeResult(
                                            day: 7,
                                            hour: 12,
                                            minute: 44
                                        )
                                    )
                                ).eraseToAnyPublisher()
                            })
                    )
            )
            .preferredColorScheme(.light)
            ProgressTaskView(
                store:
                    Store(
                        initialState: TaskState(task: .writeBook2),
                        reducer: taskReducer,
                        environment: TaskEnvironment(
                            date: Date.init,
                            calendar: .current,
                            taskProgress: { _ in
                                Just(
                                    TimeResponse(
                                        progress: 0.4,
                                        result: TimeResult(
                                            day: 7,
                                            hour: 12,
                                            minute: 44
                                        )
                                    )
                                ).eraseToAnyPublisher()
                            })
                    )
            )
            .preferredColorScheme(.dark)
        }
    }
}






extension ProgressTask {
    public static var readBook: Self {
        ProgressTask(
            title: "Read Zero to One Book",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600 * 24 * 2),
            creationDate: Date(),
            color: .endBlueLightColor,
            style: .circle
        )
    }
}

extension ProgressTask {
    public static var writeBook: Self {
        ProgressTask(
            title: "Write my Book, Write my Book, Write my Book, Write my Book",
            startDate: Date().addingTimeInterval(-3600 * 24 * 1),
            endDate: Date().addingTimeInterval(3600 * 24 * 10),
            creationDate: Date(),
            color: .endRedColor,
            style: .circle
        )
    }
}

extension ProgressTask {
    public static var writeBook2: Self {
        ProgressTask(
            title: "Write my Book2, Write my Book, Write my Book, Write my Book",
            startDate: Date().addingTimeInterval(3600 * 24 * 1),
            endDate: Date().addingTimeInterval(3600 * 24 * 2),
            creationDate: Date(),
            color: .startPinkColor,
            style: .circle
        )
    }
}

