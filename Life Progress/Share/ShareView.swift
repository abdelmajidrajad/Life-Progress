import SwiftUI
import Components
import ComposableArchitecture
import TimeClient
import Core

public enum ActivityType: String, Identifiable, CaseIterable, Equatable {
    public var id: UUID { UUID() }
    case whatsapp
    case snapchat
    case instagram
    case facebook
}

public struct ShareState: Equatable {
    var currentIndex: Int
    let yearState: YearState
    let dayState: DayState
    let switchState: SwitchState
    let yourDayState: YourDayProgressState
    let life: LifeProgressState
    let numberOfStates: Int
    public init(
        yearState: YearState = YearState(),
        dayState: DayState = DayState(),
        switchState: SwitchState = SwitchState(),
        yourDayState: YourDayProgressState = YourDayProgressState(),
        life: LifeProgressState = LifeProgressState(),
        currentIndex: Int = .zero,
        numberOfStates: Int = 5
    ) {
        self.yearState = yearState
        self.dayState = dayState
        self.switchState = switchState
        self.yourDayState = yourDayState
        self.life = life
        self.currentIndex = currentIndex
        self.numberOfStates = numberOfStates
    }
}

extension ShareState {
    var views: [AnyView] {
        [
            YearProgressView(store: Store(initialState: yearState))
                .anyView(),
            DayProgressView(store: Store(initialState: dayState))
                .anyView(),
            YourDayProgressView(store: Store(initialState: yourDayState))
                .anyView(),
            LifeProgressView(store: Store(initialState: life))
                .anyView(),
            SwitchProgressView(store: Store(initialState: switchState))
                .anyView()
        ]
    }
}


public enum ShareAction: Equatable {
    case share(UIImage)
    case activityButtonTapped(activity: ActivityType)
    case didScroll(to: Int)
    case moreButtonTapped
    case nextButtonTapped
    case previousButtonTapped
}

import Combine
struct ShareClient {
    let share: ([Any]) -> AnyPublisher<Never, Never>
    let snapShot: (AnyView) -> AnyPublisher<UIImage, Never>
}

extension Store {
    convenience init(initialState: State) {
        self.init(
            initialState: initialState,
            reducer: .empty,
            environment: ()
        )
    }
}

enum ShareProgressData: String, CaseIterable {
    case yearprogress = "Year Progress"
    case dayprogress = "Day Progress"
    case yourdayprogress = "My Day Progress"
    case lifeprogress = "My Life Progress"
    case switchprogress = "Year-Day Progress"
}

extension ShareState {
    var view: ShareView.ViewState {
        ShareView.ViewState(
            viewControllers:
                [
                    YearProgressView(store: Store(initialState: yearState)).anyView(),
                    DayProgressView(store: Store(initialState: dayState)).anyView(),
                    YourDayProgressView(store: Store(initialState: yourDayState)).anyView(),
                    LifeProgressView(store: Store(initialState: life)).anyView(),
                    SwitchProgressView(store: Store(initialState: switchState)).anyView()

                ]
                .map { $0.frame(
                    width: .py_grid(50),
                    height: .py_grid(50)
                )}
                .map { UIHostingController(rootView: $0) },
            count: 5,
            currentIndex: currentIndex
        )
    }
}


public struct ShareView: View {
    
    let store: Store<ShareState, ShareAction>
    @Environment(\.presentationMode) var presentationMode
       
    
    struct ViewState: Equatable {
        var viewControllers: [UIViewController]
        var count: Int
        var currentIndex: Int
    }
    
    init(store: Store<ShareState, ShareAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store) { viewStore in
            VStack(spacing: .py_grid(4)) {
                
                ZStack(alignment: .leading) {
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    }).buttonStyle(CloseButtonCircleStyle())
                    
                    Text("Share".uppercased())
                        .font(Font.preferred(.py_title3()).bold())
                        .frame(maxWidth: .infinity)
                    
                }
                .background(
                    RoundedRectangle(
                        cornerRadius: .py_grid(6),
                        style: .continuous
                    ).fill(Color(.secondarySystemBackground))
                    .edgesIgnoringSafeArea(.top)
                )
                
                VStack {
                                                            
                    PageView(viewStore.views
                                .map { $0.frame(
                                    width: .py_grid(50),
                                    height: .py_grid(50)
                                ) }, currentPage: viewStore.binding(
                                    get: \.currentIndex,
                                    send: ShareAction.didScroll(to:)
                                )
                    )
                    
                    
                    HStack(spacing: .py_grid(10)) {
                        Button(action: {
                            viewStore.send(.previousButtonTapped)
                        }, label: {
                            Image(systemName: "arrow.left")
                        }).buttonStyle(RoundedButtonStyle())
                        
                        Button(action: {
                            viewStore.send(.nextButtonTapped)
                        }, label: {
                            Image(systemName: "arrow.right")
                        }).buttonStyle(RoundedButtonStyle())
                    }
                                                                            
                    ApplicationView()
                    
                }.background(
                    RoundedRectangle(
                        cornerRadius: .py_grid(5),
                        style: .continuous
                    ).fill(Color(.secondarySystemBackground))
                     .shadow(radius: 0.5)
                )
                
                Spacer()
                            
                VStack(spacing: .py_grid(4)) {
                    
                    Text("Share".uppercased())
                        .font(.preferred(.py_headline()))
                        .foregroundColor(Color(.secondaryLabel))
                    
                    HStack {
//                        ForEach(ActivityType.allCases) { activity in
//                            Button(action: {
//                                viewStore.send(.activityButtonTapped(activity: activity))
//                            }, label: {
//                                Image(activity.rawValue)
//                                    .resizable()
//                            }).buttonStyle(ShareButtonStyle())
//                        }
                        
                        Button(action: {
                            viewStore.send(.moreButtonTapped)
                        }, label: {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .font(.title)
                                
                        }).buttonStyle(ShareButtonStyle())
                    }
                    
                }
                Spacer()
                
            }.padding()
        }
        
    }
}

struct ShareButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(width: .py_grid(30), height: .py_grid(15))
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(4),
                    style: .continuous
                ).fill(Color(.secondarySystemBackground))
            )
    }
}


struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShareView(store: Store(initialState: ShareState()))
            ShareView(store: Store(initialState: ShareState()))
                .preferredColorScheme(.dark)
            
            VStack {
                Text(ShareProgressData.allCases[0].rawValue)
                    .bold()
                ShareState()
                    .views[0]
                    .frame(width: .py_grid(55))
                ApplicationView()
            }.frame(width: .py_grid(80), height: .py_grid(80))
            .padding(.py_grid(1))
            .previewLayout(.sizeThatFits)
        }
    }
}

struct ApplicationView: View {
    var body: some View {
        HStack {
            Text("Progress Life")
                .font(Font.preferred(.py_footnote()).bold())
            Image("progressIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: .py_grid(8),
                    height: .py_grid(8)
                ).cornerRadius(.py_grid(2))
        }.padding()
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
