import SwiftUI
import Core
import ComposableArchitecture

struct AboutsState: Equatable {
    let features: [Feature]
    var title: String
    var version: String
    init(
        features: [Feature] = appFeatures,
        title: String = "Progress Anything ....",
        version: String = "© Life Progress v\(appVersion)"
    ) {
        self.features = features
        self.title = title
        self.version = version
    }
}

struct AboutsView: View {
    
    let store: Store<AboutsState, Never>
    public init(store: Store<AboutsState, Never>) {
        self.store = store
    }
    
    @Environment(\.colorScheme) var colorScheme
    private var image: String {
        colorScheme == .dark ? "orange": "classic"
    }
    
    var body: some View {
                                                    
        WithViewStore(store) { viewStore in
                            
                VStack {
                    
                    Text(
                        "Life progress is for anything that have a start and end like a task, a day or life."
                    )
                    .padding()
                    .font(.preferred(.py_body()))
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.center)
                                                            
                    VStack {
                        Text(viewStore.title)
                            //.frame(maxHeight: .infinity, alignment: .bottom)
                            .multilineTextAlignment(.center)
                        Image(image, bundle: .settings)
                            .resizable()
                            .frame(
                                width: .py_grid(15),
                                height: .py_grid(15)
                            ).clipShape(
                                RoundedRectangle(
                                    cornerRadius: .py_grid(5),
                                    style: .continuous
                                )
                            )
                        Text(viewStore.version)
                            .font(.preferred(.py_callout()))
                            .foregroundColor(.gray)
                    }
                    
                                        
                }.frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
                .navigationBarTitle(
                    Text("About"), displayMode: .automatic
                )
            
        }
        
    }
}

struct AboutsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutsView(store: Store<AboutsState, Never>(
                        initialState: AboutsState(),
                        reducer: .empty,
                        environment: ())
            )
            NavigationView {
                AboutsView(store: Store<AboutsState, Never>(
                            initialState: AboutsState(),
                            reducer: .empty,
                            environment: ())
                ).preferredColorScheme(.dark)
            }
            
            FeatureView(feature: .yearProgress)
        }
    }
}

public struct Feature: Identifiable, Equatable {
    public var id: UUID = UUID()
    let title: String
    let subTitle: String
    let imageSystemName: String
}

public let appFeatures: [Feature] = [
    .yearProgress,
    .todayProgress,
    .yourDayProgress,
    .widget,
    .taskProgress
]

extension Feature {
    static var yearProgress: Self {
        .init(
            title: "year progress",
            subTitle: "track daily progress, how much days left to the end",
            imageSystemName: "calendar"
        )
    }
    
    static var todayProgress: Self {
        .init(
            title: "today progress",
            subTitle: "track remaining hours to the end of today",
            imageSystemName: "clock"
        )
    }
    
    static var yourDayProgress: Self {
        .init(
            title: "your day progress",
            subTitle: "track remaining hours to the end your day",
            imageSystemName: "deskclock"
        )
    }
    
    static var widget: Self {
        .init(
            title: "Widgets",
            subTitle: "Add widget on your main screen",
            imageSystemName: "app.fill"
        )
    }
    
    static var taskProgress: Self {
        .init(
            title: "Task Progress",
            subTitle: "track your tasks and add them on Widgets",
            imageSystemName: "checkmark"
        )
    }
    
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

