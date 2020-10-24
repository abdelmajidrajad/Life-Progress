import SwiftUI
import Components

struct ProgressTask: Identifiable, Equatable {
    var id: UUID = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
}

struct ProgressTaskState: Equatable {
    let task: ProgressTask
    var remainingTime: NSAttributedString
    var progress: Double
    init(
        task: ProgressTask,
        remainingTime: NSAttributedString = .init(),
        progress: Double = .zero
    ) {
        self.task = task
        self.progress = progress
        self.remainingTime = remainingTime
    }
}


import TimeClient
import Combine
struct TaskEnvironment {
    let taskProgress: (TaskRequest) -> AnyPublisher<TaskResponse, Never>
}

enum ProgressTaskAction: Equatable {
    case onAppear
}


import ComposableArchitecture
let taskReducer = Reducer<ProgressTaskState, ProgressTaskAction, Void> { state, action, _ in
    return .none
}


extension ProgressTaskState {
    var view: ProgressTaskView.ViewState {
        .init(
            title: task.title,
            remaining: "test",
            progress: NSNumber(value: progress)
        )
    }
}

struct ProgressTaskView: View {
    
    struct ViewState: Equatable {
        let title: String
        let remaining: String
        let progress: NSNumber
    }
    
    let store: Store<ProgressTaskState, ProgressTaskAction>
    
    init(store: Store<ProgressTaskState, ProgressTaskAction>) {
        self.store = store
    }
    var body: some View {
        WithViewStore(self.store.scope(state: \.view)) { viewStore in
        VStack(alignment: .leading, spacing: .py_grid(2)) {
            
            Text(viewStore.title)
                .font(.headline)
                .frame(
                    maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                    alignment: .leading
                ).padding(.trailing, .py_grid(4))
                .lineLimit(1)
                
            
            Text(viewStore.remaining)
                .font(.subheadline)
                .fontWeight(.light)
            
            ProgressBar(
                color: .pink,
                lineWidth: .py_grid(2),
                labelHidden: true,
                progress: .constant(viewStore.progress)
            )
            
        }.padding()
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(
                    cornerRadius: 8.0, style: .continuous)
                    .fill(Color.white)
                    .shadow(radius: 0.3)
                Button(action: {}, label: {
                    Image(systemName: "ellipsis")
                        .accentColor(.secondary)
                }).padding()
            }
        )
        .padding(.horizontal)
        }
    }
}

struct ProgressTaskView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTaskView(
            store:
                Store(
                    initialState: ProgressTaskState(task: .readBook),
                    reducer: .empty,
                    environment: Void()
                )
        )
    }
}


extension ProgressTask {
    static var readBook: Self {
        ProgressTask(
            title: "Read Zero to One Book",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600 * 24 * 2)
        )
    }
}


