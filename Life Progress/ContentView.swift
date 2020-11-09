import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import TaskClient
import Components
import Tasks
import Settings


struct ContentView: View {
    
    let store: Store<AppState, AppAction>
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
    }
    
    var body: some View {
        GeometryReader { proxy -> AnyView in
            let width = proxy.size.width * 0.5 - 8.0
            return AnyView(
                WithViewStore(store) { viewStore in
                    ScrollView {
                        
                        Section(header:
                            ZStack(alignment: .trailing) {
                                Text("Widgets")
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                Button(action: {
                                    viewStore.send(.settingButtonTapped)
                                }, label: {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.gray)
                                })
                                .sheet(
                                    isPresented: viewStore.binding(
                                        get: { $0.settingState != nil },
                                        send: AppAction.viewDismissed
                                    )
                                ) {
                                    IfLetStore(store.scope(
                                        state: \.settingState,
                                        action: AppAction.settings
                                    )) { settingStore in
                                        NavigationView {
                                            SettingsView(store: settingStore)
                                        }
                                    }
                                }
                                
                                
                            }.padding()
                             .font(Font
                                    .preferred(.py_title2()).bold()
                             ).foregroundColor(Color(.lightText))
                        ) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: .py_grid(4)) {
                                    
                                    YourDayProgressView(
                                        store: store.scope(
                                            state: \.yourDayState,
                                            action: AppAction.yourDay)
                                    )
                                    
                                    SwitchProgressView(
                                        store: store.scope(
                                            state: \.switchState,
                                            action: AppAction.union
                                        )
                                    )
                                    
                                    DayProgressView(
                                        store: store.scope(
                                            state: \.dayState,
                                            action: AppAction.day)
                                    )
                                    
                                    YearProgressView(
                                        store: store.scope(
                                            state: \.yearState,
                                            action: AppAction.year)
                                    )
                                
                                                            
                                }.padding(.vertical)
                                .padding(.horizontal, .py_grid(1))
                            }.frame(height: width)
                        }
                        
                        TasksView(store:
                            store.scope(
                                state: \.tasksState,
                                action: AppAction.tasks)
                        )                                               
                        
                    }.padding(.leading, .py_grid(1))
                    .onAppear {
                        viewStore.send(.onStart)
                    }
                }
            )
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(
                store: Store<AppState, AppAction>(
                    initialState: AppState(
                        tasksState: TasksState(filter: .pending)
                    ),
                    reducer: appReducer,
                    environment: .midDay
                )
            ).preferredColorScheme(.dark)
            ContentView(
                store: Store<AppState, AppAction>(
                    initialState: AppState(
                        tasksState: TasksState(filter: .pending)
                    ),
                    reducer: appReducer,
                    environment: .midDay
                )
            )
        }
    }
}

extension AppEnvironment {
    static var empty: Self {
        Self(
            uuid: UUID.init,
            date: Date.init,
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: .empty,
            taskClient: .empty,
            context: .init(concurrencyType: .privateQueueConcurrencyType),
            userDefaults: UserDefaults()
        )
    }
}

import Combine
extension AppEnvironment {
    static var midDay: Self {
        Self(
            uuid: UUID.init,
            date: { Date(timeIntervalSince1970: 3600 * 24 * 6) },
            calendar: .current,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            timeClient: TimeClient(
                yearProgress: { _ in Just(TimeResponse(
                    progress: 0.38,
                    result: TimeResult(
                        hour: 13, minute: 12
                    )
                )).eraseToAnyPublisher()
                }, todayProgress: { _ in
                    Just(TimeResponse(
                    progress: 0.8,
                    result: TimeResult(
                        day: 19, hour: 13
                    )
                )).eraseToAnyPublisher()
                }, taskProgress: { _ in
                    Just(
                        TimeResponse(
                            progress: 0.76,
                            result: TimeResult(
                                //year: 2,
                                //month: 1,
                                day: 7,
                                hour: 12,
                                minute: 44
                            )
                        )
                    ).eraseToAnyPublisher()
                }, yourDayProgress: { _ in
                    Just(
                        TimeResponse(
                            progress: 0.76,
                            result: TimeResult(
                                //year: 2,
                                //month: 1,
                                //day: 7,
                                hour: 6,
                                minute: 44
                            )
                        )
                    ).eraseToAnyPublisher()
                }
                
            ), taskClient:
                TaskClient(tasks: { _ in
                    Just(TaskResponse.tasks([
                        .readBook, .writeBook, .writeBook2
                    ]))
                        .setFailureType(to: TaskFailure.self)
                        .eraseToAnyPublisher()
                }),
            context: .init(concurrencyType: .privateQueueConcurrencyType),
            userDefaults: UserDefaults()
        )
    }
}



struct RoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .font(Font.preferred(.py_title2()).bold().smallCaps())
            .padding(.vertical)
            .padding(.horizontal, .py_grid(6))
            .background(
                RoundedRectangle(cornerRadius: .py_grid(4))                .fill(Color(white: 0.97))
            )
    }
}

struct PlusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, .py_grid(5))
            .padding(.vertical, .py_grid(3))
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(Color.white)
                    .shadow(color: Color(white: 0.95), radius: 1)
            )
    }
}
