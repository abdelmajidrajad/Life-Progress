import SwiftUI
import Core
import ComposableArchitecture

public struct AppFeatureState: Equatable {
    let features: [Feature]
    var currentIndex: Int
    public init(
        features: [Feature],
        currentIndex: Int = .zero
    ) {
        self.features = features
        self.currentIndex = currentIndex
    }
}

public enum AppFeatureAction: Equatable {
    case buyButtonTapped
    case indexChanged(Int)
}

let appFeatureReducer =
    Reducer<AppFeatureState, AppFeatureAction, Void> {
        state, action, _ in
        switch action {
        case .buyButtonTapped:
            return .none
        case let .indexChanged(newIndex):
            state.currentIndex = newIndex
            return .none
        }
        
    }



public struct AppFeaturesView: View {
    let store: Store<AppFeatureState, AppFeatureAction>
    public init(
        store: Store<AppFeatureState, AppFeatureAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
                
        WithViewStore(store) { viewStore in
            ZStack(alignment: .bottom) {
                
                PageView(
                    viewStore.features.map(FeatureView.init),
                    currentPage: viewStore.binding(
                        get: \.currentIndex,
                        send: AppFeatureAction.indexChanged
                    )
                )
                
                VStack {

                    PageControl(
                        numberOfPages: viewStore.features.count,
                        currentPage: viewStore.binding(
                            get: \.currentIndex,
                            send: AppFeatureAction.indexChanged
                        )
                    ).zIndex(1)
                    Button(action: {
                        viewStore.send(.buyButtonTapped)
                    }, label: {
                        Text("Full 2.99$")
                            .font(Font.preferred(.py_title3()).bold())
                            .foregroundColor(Color(.label))
                            .padding()
                            .padding(.horizontal)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                    })
                    .frame(maxWidth: .infinity, maxHeight: .py_grid(25))
                    .padding(.bottom)
                    .background(
                        VisualEffectBlur(blurStyle: .extraLight)
                            .cornerRadius(.py_grid(10))
                    )
                }
                
            }.edgesIgnoringSafeArea(.all)
            
        }        
    }
}

struct AppFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        AppFeaturesView(store: Store(
                            initialState: AppFeatureState(features: appFeatures),
                            reducer: appFeatureReducer,
                            environment: ()
        ))
    }
}
