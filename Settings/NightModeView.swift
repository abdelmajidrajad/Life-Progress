import SwiftUI
import ComposableArchitecture
import Core


public struct NightModeState: Equatable {
    public enum Style: String, CaseIterable, Equatable {
        case dark, light, automatic
    }
    let styles: [Style]
    var currentStyle: Style
    public init(
        styles: [Style] = Style.allCases,
        currentStyle: Style = .automatic
    ) {
        self.styles = styles
        self.currentStyle = currentStyle
    }
}

public enum NightModeAction: Equatable {
    case onAppear
    case setStyle(NightModeState.Style)
    case onStyleChanged(NightModeState.Style)
}

var userInterface: UIUserInterfaceStyle {
    UIScreen.main.traitCollection.userInterfaceStyle
}

public let nightModeReducer =
    Reducer<NightModeState, NightModeAction, KeyValueStoreType> {
        state, action, storage in
        switch action {
        case .onAppear:
            if let storedStyle = storage.string(forKey: "style"),
               let style = NightModeState.Style(rawValue: storedStyle) {
                state.currentStyle = style
            }
            return .none
        case let .onStyleChanged(newStyle):
            state.currentStyle = newStyle
            storage.set(newStyle.rawValue, forKey: "style")
            return Effect(value: .setStyle(newStyle))
        case let .setStyle(style):
            state.currentStyle = style
            return .fireAndForget {
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle =
                        style == .dark ? .dark:
                        style == .light ? .light: .unspecified
                }
            }
        }
    }


func imageName(for style: NightModeState.Style) -> String {
    style == .dark
    ? "moon.fill"
    : style == .light
    ? "sun.min.fill"
    : "sunset.fill"
}

func fillColor(for style: NightModeState.Style) -> Color {
    style == .dark
        ? Color.purple
        : style == .light
        ? Color.orange
        : .yellow
}

public struct NightModeView: View {
    
    let store: Store<NightModeState, NightModeAction>
    
    public init(store: Store<NightModeState, NightModeAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEach(viewStore.styles, id: \.self) { style in
                    HStack {
                        Image(systemName:
                                imageName(for: style)
                        )
                        .padding(.py_grid(2))
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(
                                cornerRadius: .py_grid(2),
                                style: .continuous
                            ).fill(
                                fillColor(for: style)
                            )
                        )
                        Text(style.rawValue)
                            .font(
                                Font.preferred(.py_headline()).smallCaps()
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        
                        if style == viewStore.currentStyle {
                            Image(systemName: "checkmark")
                                .font(.headline)
                        }
                    }.font(Font.preferred(.py_body()))
                    .padding(.vertical, .py_grid(3))
                    .background(
                        Rectangle().fill(Color(.systemBackground))
                    ).onTapGesture {
                        viewStore.send(.onStyleChanged(style))
                    }
                }
            }.navigationBarTitle(Text("Appearance"))
            .onAppear {
                viewStore.send(.onAppear)
            }.foregroundColor(Color(.label))
            
        }
    }
}

struct NightModeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NightModeView(store: Store<NightModeState, NightModeAction>.init(
                            initialState: NightModeState(),
                            reducer: nightModeReducer,
                            environment: TestUserDefault()
            ))
            NightModeView(store: Store<NightModeState, NightModeAction>.init(
                            initialState: NightModeState(),
                            reducer: nightModeReducer,
                            environment: TestUserDefault()
            ))
                .preferredColorScheme(.light)
        }
    }
}
