import SwiftUI
import Core
import ComposableArchitecture
import Components
import Tasks
import Settings


struct ContentView: View {
    
    let store: Store<AppState, AppAction>
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
    }
    
    @State var isScaled: Bool = false
    
    var body: some View {
        GeometryReader { proxy -> AnyView in
            let width = proxy.size.width * 0.5 - .py_grid(2)
                        return AnyView(
                WithViewStore(store) { viewStore in
                    ZStack(alignment: .bottomLeading) {
                        
                        Button(action: {
                            viewStore.send(.shareButtonTapped)
                        }) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.title)
                                .foregroundColor(Color(.label))
                        }.padding()
                        .background(EmptyView())
                        .sheet(isPresented: viewStore.binding(
                                get: { $0.shareState != nil },
                                send: AppAction.viewDismissed)) {
                            
                            IfLetStore(store.scope(
                                state: \.shareState,
                                action: AppAction.share
                            )) { shareStore in
                                ShareView(store: shareStore)
                            }
                            
                        }.zIndex(1.0)
                        
                        ScrollView {
                            Section(header:
                                ZStack(alignment: .trailing) {
                                    Text("Widgets")
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        ).foregroundColor(Color(.label))

                                    Button(action: {
                                        viewStore.send(.settingButtonTapped)
                                    }, label: {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(Color(.label))
                                    }).background(EmptyView())
                                    .sheet(
                                        isPresented: viewStore.binding(
                                            get: { $0.settingState != nil },
                                            send: AppAction.viewDismissed
                                        )
                                    )
                                    {
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
                                 .font(Font.preferred(.py_title2()).bold())
                                 .foregroundColor(Color(.lightText))
                            ) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: .py_grid(4)) {
                                        
                                        LifeProgressView(store:
                                            store.scope(
                                                state: \.life,
                                                action: AppAction.life
                                        ))
                                        
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
                                     .frame(height: width)
                                }.frame(height: width)
                            }

                            TasksView(store:
                                store.scope(
                                    state: \.tasksState,
                                    action: AppAction.tasks)
                            )
                            
                            Spacer(minLength: .py_grid(20))

                        }.padding(.leading, .py_grid(1))
                        .onAppear {
                            viewStore.send(.onStart)
                        }
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
                        
                    ),
                    reducer: appReducer,
                    environment: .midDay
                )
            )
        }
    }
}

import TaskClient


