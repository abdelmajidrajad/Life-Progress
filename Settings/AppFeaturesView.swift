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

public let appFeatureReducer =
    Reducer<AppFeatureState, AppFeatureAction, Void> {
        state, action, _ in
        switch action {
        case .buyButtonTapped:
            return .none
        case .closeButtonTapped:
            return .none
        }
    }

//Binding<PresentationMode>

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
                                        
                VStack {
                                        
                    PageView(
                        viewStore.features.map(FeatureView.init),
                        currentPage: $currentPage
                    )
                    
                    Spacer()
                                                                   
                    Button(action: {
                        //viewStore.send(.buyButtonTapped)
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Skip")
                            .font(Font.preferred(.py_title3()).bold())
                            .foregroundColor(Color.white)
                            .padding(.py_grid(3))
                            .padding(.horizontal, .py_grid(3))
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                    }).frame(
                        maxWidth: .infinity,
                        maxHeight: .py_grid(20),
                        alignment: .trailing
                    ).padding(.trailing)
                }
                                    
//
//                Button(action: {
//                    viewStore.send(.closeButtonTapped)
//                    presentationMode.wrappedValue.dismiss()
//                }, label: {
//                    Image(systemName: "xmark")
//                }).padding()
//                .buttonStyle(CloseButtonCircleStyle())
            }
            
        }        
    }
}


struct FeatureView: View {
    let feature: Feature
    var body: some View {
        ZStack {
            VStack(
                alignment: .center,
                spacing: .py_grid(4)
            ) {
                HStack {
                    
                    ForEach(1 ..< 6) { item in
                        VisualEffectBlur(
                            blurStyle: .extraLight
                        ).frame(
                            width: .py_grid(3),
                            height: .py_grid(9)
                        )
                        .opacity(Double(item) / 5.0)
                        .clipShape(Capsule())
                        
                    }
                }.padding()
                
                
                Text(feature.title.uppercased())
                    .font(Font.preferred(.py_title3(size: .py_grid(8))).bold())
                    .foregroundColor(Color(.label))
                    .padding()
                
                Image(systemName: feature.imageSystemName)
                    .foregroundColor(.white)
                    .font(Font.title.bold())
                    .padding(.py_grid(8))
                    .background(
                        RoundedRectangle(
                            cornerRadius: .py_grid(4),
                            style: .continuous
                        ).fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        .orange,
                                        .pink,
                                        .orange
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                ).transition(.asymmetric(
                    insertion: .scale,
                    removal: .scale(scale: 0.5)
                ))
                .animation(.linear)
                
                Text(feature.subTitle.capitalizingFirstLetter())
                    .font(.preferred(.py_body()))
                    .padding(.horizontal)
                    .foregroundColor(Color(.secondaryLabel))
                
            }.padding(.vertical)
            .multilineTextAlignment(.center)
            .padding(.top, .py_grid(20))
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
    }
}

struct AppFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppFeaturesView(store: Store(
                                initialState: AppFeatureState(features: appFeatures),
                                reducer: appFeatureReducer,
                                environment: ()
            ))
            AppFeaturesView(store: Store(
                initialState: AppFeatureState(features: appFeatures),
                reducer: appFeatureReducer,
                environment: ()
            ))
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12")
        }
    }
}
