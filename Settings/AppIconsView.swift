import SwiftUI
import Core
import ComposableArchitecture
import Combine

public struct AppIconState: Equatable {
    let icons: [AppIcon]
    var chosenIcon: AppIcon?
    public init(
        icons: [AppIcon] = AppIcon.allCases,
        chosenIcon: AppIcon? = nil
    ) {
        self.icons = icons
        self.chosenIcon = chosenIcon
    }
}

public enum AppIconAction: Equatable {
    case onAppear
    case pickedIcon(AppIcon)
}

var alternateIconName: Effect<AppIcon, Never>  {
    Effect<AppIcon, Never>.future { promise in
        promise(.success(
            AppIcon(rawValue: UIApplication.shared.alternateIconName ?? "classic") ?? .classic
        ))
    }.eraseToEffect()
}

let appIconReducer =
Reducer<AppIconState, AppIconAction, Void> { state, action, _ in
    switch action {
    case .onAppear:
        return alternateIconName
            .map(AppIconAction.pickedIcon)
    case let .pickedIcon(icon):
        state.chosenIcon = icon
        return .none
    }
}

struct AppIconsView: View {
    
    let store: Store<AppIconState, AppIconAction>
    public init(
        store: Store<AppIconState, AppIconAction>
    ) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    HStack {
                        Image(icon.rawValue, bundle: .settings)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: .py_grid(16),
                                height: .py_grid(16)
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: .py_grid(3),
                                    style: .continuous
                                )
                            )
                        
                        Text(icon.rawValue)
                            .foregroundColor(Color(.label))
                            .font(
                                Font.preferred(.py_body())
                                    .lowercaseSmallCaps()
                            ).frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        
                        if icon == viewStore.chosenIcon {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(.label))
                                .font(.preferred(.py_headline()))
                        }
                    }.background(
                        Rectangle()
                            .fill(Color(.systemBackground))
                    )
                    .onTapGesture {
                        viewStore.send(.pickedIcon(icon))
                    }
                }
            }.navigationBarTitle(Text("App Icons"))
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AppIconsView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconsView(
            store: Store<AppIconState, AppIconAction>(
                initialState: AppIconState(),
                reducer: appIconReducer,
                environment: ()
            )
        ).preferredColorScheme(.dark)
            
    }
}
