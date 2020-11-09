import SwiftUI
import ComposableArchitecture


public struct NightModeState: Equatable {
    public enum Style: CaseIterable, Equatable {
        case dark, light
    }
    let styles: [Style] = Style.allCases
    var currentStyle: Style = .light
}

public enum NightModeAction: Equatable {
    case onAppear
    case setStyle(NightModeState.Style)
    case onStyleChanged(NightModeState.Style)
}

public let nightModeReducer =
    Reducer<NightModeState, NightModeAction, Void> {
        state, action, _ in
        switch action {
        case .onAppear:
            let currentStyle: NightModeState.Style =
                UIScreen.main.traitCollection.userInterfaceStyle == .dark
                ? .dark
                : .light
            return Effect(value: .setStyle(currentStyle))
        case let .onStyleChanged(newStyle):
            state.currentStyle = newStyle
            return .fireAndForget {
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle =
                        newStyle == .dark ? .dark: .light
                }
            }
        case let .setStyle(style):
            state.currentStyle = style
            return .none
        }
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
                              style == .dark
                              ? "moon.fill"
                              : "sun.min.fill"
                            )
                            .padding(.py_grid(2))
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: .py_grid(2),
                                    style: .continuous
                                ).fill(
                                    style == .dark
                                     ? Color.purple
                                     : .orange
                                )
                            )
                        Text(style == .dark ? "Dark": "Light")
                            .font(Font.preferred(.py_subhead()).bold())
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
                }.onAppear {
                    viewStore.send(.onAppear)
                }
            }.navigationBarTitle(Text("Appearance"))
            
        }
    }
}

struct NightModeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NightModeView(store: Store<NightModeState, NightModeAction>.init(
                            initialState: NightModeState(),
                            reducer: nightModeReducer,
                            environment: ()
            ))
            NightModeView(store: Store<NightModeState, NightModeAction>.init(
                            initialState: NightModeState(),
                            reducer: nightModeReducer,
                            environment: ()
            ))
                .preferredColorScheme(.dark)
        }
    }
}
