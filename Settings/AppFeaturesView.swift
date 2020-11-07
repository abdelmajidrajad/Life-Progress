import SwiftUI
import Core
import ComposableArchitecture

public struct AppFeatureState: Equatable {
    let features: [Feature]
    public init(
        features: [Feature]
    ) {
        self.features = features
    }
}

public enum AppFeatureAction: Equatable {
    case buyButtonTapped
    case closeButtonTapped
}

let appFeatureReducer =
    Reducer<AppFeatureState, AppFeatureAction, Void> {
        state, action, _ in
        switch action {
        case .buyButtonTapped:
            return .none
        case .closeButtonTapped:
            return .none
        }
        
    }



public struct AppFeaturesView: View {
    let store: Store<AppFeatureState, AppFeatureAction>
    @State var currentPage: Int = .zero
    @Environment(\.presentationMode) var presentationMode
    public init(
        store: Store<AppFeatureState, AppFeatureAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
                
        WithViewStore(store) { viewStore in
            ZStack(alignment: .topLeading) {
                                                
                ZStack(alignment: .bottom) {
                    
                    PageView(
                        viewStore.features.map(FeatureView.init),
                        currentPage: $currentPage
//                        currentPage: viewStore.binding(
//                            get: \.currentIndex,
//                            send: AppFeatureAction.indexChanged
//                        )
                    )
                    
                    VStack {

                        PageControl(
                            numberOfPages: viewStore.features.count,
                            currentPage: $currentPage
//                            currentPage: viewStore.binding(
//                                get: \.currentIndex,
//                                send: AppFeatureAction.indexChanged
//                            )
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
                        }).frame(
                            maxWidth: .infinity,
                            maxHeight: .py_grid(25)
                        ).padding(.bottom)
                         .background(
                            VisualEffectBlur(blurStyle: .extraLight)
                                .cornerRadius(.py_grid(10))
                        )                                                
                    }
                    
                }.edgesIgnoringSafeArea(.all)
                
                Button(action: {
                    //viewStore.send(.closeButtonTapped)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                }).padding()
                .buttonStyle(CloseButtonCircleStyle())
                
            }
            
        }        
    }
}


struct CloseButtonCircleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1: 1.0)
            .padding()
            .font(.headline)
            .foregroundColor(Color(.secondaryLabel))
            .background(
                VisualEffectBlur(blurStyle: .extraLight)
                    .clipShape(Circle())
            )

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
