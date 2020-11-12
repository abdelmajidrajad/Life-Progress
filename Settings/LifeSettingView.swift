import SwiftUI
import Core


let numberFormatter: () -> NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.allowsFloats = true
    formatter.numberStyle = .decimal
    return formatter
}

public struct LifeSettingState: Equatable {
    var life: Float
    var age: Float
    var didChange: Bool = false
    public init(
        life: Float = 120,
        age: Float = 30
    ) {
        self.life = life
        self.age = age
    }
    
}

public enum LifeSettingAction: Equatable {
    case onAppear
    case setAge(Float)
    case setLife(Float)
    case saveButtonTapped
}

public struct LifeSettingEnvironment {
    let userDefaults: KeyValueStoreType
    let mainQueue: AnySchedulerOf<DispatchQueue>
}


import ComposableArchitecture
public let lifeSettingReducer =
    Reducer<LifeSettingState, LifeSettingAction, LifeSettingEnvironment> {
        state, action, environment in
        
        switch action {
        case .onAppear:
            state.age = Float(
                environment.userDefaults.integer(forKey: "age") == .zero
                ? 5
                : environment.userDefaults.integer(forKey: "age")
            )
            state.life = Float(
                environment.userDefaults.integer(forKey: "life") == 0
                    ? 80
                    : environment.userDefaults.integer(forKey: "life")
            )
            return .none
        case let .setAge(age):
            state.age = age
            state.didChange = environment
                .userDefaults
                .integer(forKey: "age") != Int(age)
            return .none
        case let .setLife(life):
            if life < state.age {
                state.age = life
            }
            let age = state.age
            state.life = life
            state.didChange = environment
                .userDefaults
                .integer(forKey: "life") != Int(life)
            return .none
        case .saveButtonTapped:
            environment.userDefaults.set(state.age, forKey: "age")
            environment.userDefaults.set(state.life, forKey: "life")
            return .none
        }
    }

extension LifeSettingState {
    var view: LifeSettingView.ViewState {
        .init(
            life: life,
            age: age,
            didChange: didChange,
            lifeRange: 20...120,
            ageRange: 5...life,
            lifeStep: 2,
            ageStep: 1
        )
    }
}

public struct LifeSettingView: View {
    
    struct ViewState: Equatable {
        var life: Float
        var age: Float
        var didChange: Bool
        var lifeRange: ClosedRange<Float>
        var ageRange: ClosedRange<Float>
        var lifeStep: Float
        var ageStep: Float
    }
    
    let store: Store<LifeSettingState, LifeSettingAction>
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(store: Store<LifeSettingState, LifeSettingAction>) {
        self.store = store
    }
    
    public var body: some View {
                            
        WithViewStore(store.scope(state: \.view)) { viewStore in
            VStack {
                                                                       
                VStack(alignment: .leading, spacing: .py_grid(3)) {
                    
                    Text("Life")
                        .font(Font.preferred(.py_title2()).bold())
                        .foregroundColor(Color(.label))
                    
                    Text("Set the age you want to achieve all your dreams")
                        .font(Font.preferred(.py_body()))
                        .foregroundColor(Color(.secondaryLabel))
                    
                    HStack(spacing: .py_grid(4)) {
                        
                        Image(systemName: "heart.fill")
                            .font(.preferred(.py_title2()))
                            .foregroundColor(.red)
                        
                        Slider(
                            value: viewStore.binding(
                                get: \.life,
                                send: LifeSettingAction.setLife
                            ),
                            in: viewStore.lifeRange,
                            step: viewStore.lifeStep
                        ).labelsHidden()
                        .accentColor(.red)
                        
                        Text(NSNumber(value: viewStore.life), formatter: numberFormatter())
                            .font(.preferred(.py_headline()))
                            .foregroundColor(Color.red)
                            .frame(width: .py_grid(10), height: .py_grid(10))
                            .background(
                                RoundedRectangle(cornerRadius: .py_grid(4))
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    
                    Text("Age")
                        .font(Font.preferred(.py_title2()).bold())
                        .foregroundColor(Color(.label))
                    
                    Text("Set your current age")
                        .font(Font.preferred(.py_body()))
                        .foregroundColor(Color(.secondaryLabel))
                    
                    HStack(spacing: .py_grid(4)) {
                        
                        Image(systemName: "leaf.fill")
                            .font(.preferred(.py_title2()))
                            .foregroundColor(.green)
                        
                        Slider(
                            value: viewStore.binding(
                                get: \.age,
                                send: LifeSettingAction.setAge
                            ),
                            in: viewStore.ageRange,
                            step: viewStore.ageStep
                        ).labelsHidden()
                        .accentColor(.green)
                        
                        Text(NSNumber(value: viewStore.age), formatter: numberFormatter())
                            .font(.preferred(.py_headline()))
                            .foregroundColor(Color.green)
                            .frame(width: .py_grid(10), height: .py_grid(10))
                            .background(
                                RoundedRectangle(cornerRadius: .py_grid(4))
                                    .fill(Color.green.opacity(0.1))
                            )
                    }
                    
                }.padding()
                
                Spacer()
                
                ProgressCircle(
                    color: .green,
                    lineWidth: .py_grid(5),
                    labelHidden: false,
                    progress: .constant(
                        NSNumber(value: viewStore.age / viewStore.life)
                    )
                ).frame(
                    width: .py_grid(30),
                    height: .py_grid(30)
                )
                
                Spacer()
                
                Text("Never say too late, make an action and make an action now")
                    .multilineTextAlignment(.center)
                    .font(.preferred(.py_footnote()))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Rectangle().fill(Color(.systemGroupedBackground))
                    )
            }.onAppear {
                viewStore.send(.onAppear)
            }.navigationBarItems(trailing:
                    Button(
                        action: {
                            viewStore.send(.saveButtonTapped)
                            presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            Text("Save")
                                .foregroundColor(
                                    viewStore.didChange ? Color.blue: .gray
                                )
                    }).disabled(!viewStore.didChange)
            )
        }
    }
}

struct LifeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LifeSettingView(store: Store(
                initialState: LifeSettingState(),
                reducer: lifeSettingReducer,
                environment: LifeSettingEnvironment(
                    userDefaults: TestUserDefault(),
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )).navigationBarTitle(Text("Life Progress"))
            
        }
    }
}
