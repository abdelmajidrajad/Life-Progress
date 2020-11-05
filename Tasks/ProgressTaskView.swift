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
    public init(
        task: ProgressTask,
        remainingTime: NSAttributedString = .init(),
        progress: Double = .zero,
        result: TimeResult = .init(),
        status: Status = .active,
        isSelected: Bool = false
    ) {
        self.task = task
        self.progress = progress
        self.remainingTime = remainingTime
        self.result = result
        self.isSelected = isSelected
        self.status = status
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
        case .ellipseButtonTapped:
            state.isSelected.toggle()
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
            isCircle: task.style == .circle
        )
    }
}

struct ProgressTaskView: View {
    
    struct ViewState: Equatable {
        let title: String
        let remaining: NSAttributedString
        let progress: NSNumber
        let color: Color
        let isCircle: Bool
    }
    
    let store: Store<TaskState, TaskAction>
    let ellipseButtonTapped: () -> Void
    
    init(
        store: Store<TaskState, TaskAction>,
        ellipseButtonTapped: @escaping () -> Void = {}
    ) {
        self.store = store
        self.ellipseButtonTapped = ellipseButtonTapped
    }
    var body: some View {
        
        WithViewStore(self.store.scope(state: \.view)) { viewStore in
            VStack {
                if viewStore.isCircle {
                    HStack {
                        
                        ProgressCircle(
                            color: viewStore.color,
                            lineWidth: .py_grid(3),
                            labelHidden: false,
                            progress: .constant(viewStore.progress)
                        ).frame(width: .py_grid(20))
                        
                        VStack(alignment: .leading, spacing: .py_grid(2)) {
                            Text(viewStore.title)
                                .font(.preferred(.py_body()))
                                .frame(
                                    maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                                    alignment: .leading
                                ).padding(.trailing, .py_grid(4))
                                .lineLimit(2)
                            
                            PLabel(attributedText: .constant(viewStore.remaining))
                                .fixedSize()
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
                            
                            PLabel(attributedText: .constant(viewStore.remaining))
                                .fixedSize()
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
                    
                    Button(action: ellipseButtonTapped,
                           label: {
                            Image(systemName: "ellipsis")
                                .font(.headline)
                                .accentColor(.gray)
                           }
                    ).padding()
                }
            ).padding(.horizontal)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct ProgressTaskView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressTaskView(
                store:
                    Store(
                        initialState: TaskState(task: .writeBook),
                        reducer: taskReducer,
                        environment: TaskEnvironment(
                            date: Date.init,
                            calendar: .current,
                            taskProgress: { _ in
                                Just(
                                    TimeResponse(
                                        progress: 0.4,
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
                    )
            )
            .preferredColorScheme(.light)
            ProgressTaskView(
                store:
                    Store(
                        initialState: TaskState(task: .readBook),
                        reducer: taskReducer,
                        environment: TaskEnvironment(
                            date: Date.init,
                            calendar: .current,
                            taskProgress: { _ in
                                Just(
                                    TimeResponse(
                                        progress: 0.4,
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
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600 * 24 * 10),
            creationDate: Date(),
            color: .endRedColor,
            style: .bar
        )
    }
}

extension ProgressTask {
    public static var writeBook2: Self {
        ProgressTask(
            title: "Write my Book2, Write my Book, Write my Book, Write my Book",
            startDate: Date().addingTimeInterval(-3600 * 24 * 1),
            endDate: Date().addingTimeInterval(3600 * 24 * 3),
            creationDate: Date(),
            color: .startPinkColor
        )
    }
}

