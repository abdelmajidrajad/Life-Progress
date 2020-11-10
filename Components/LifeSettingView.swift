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
}

import ComposableArchitecture
public let lifeSettingReducer =
    Reducer<LifeSettingState, LifeSettingAction, Void> {
        state, action, _ in
        switch action {
        case .onAppear:
            return .none
        case let .setAge(age):
            state.age = age
            return .none
        case let .setLife(life):
            
            if life < state.age {
                state.age = life
            }
            
            state.life = life
            return .none
        }
    }

extension LifeSettingState {
    var view: LifeSettingView.ViewState {
        .init(
            life: life,
            age: age,
            lifeRange: 20...120,
            ageRange: 5...life,
            lifeStep: 2,
            ageStep: 1
        )
    }
}

struct LifeSettingView: View {
    
    struct ViewState: Equatable {
        var life: Float
        var age: Float
        var lifeRange: ClosedRange<Float>
        var ageRange: ClosedRange<Float>
        var lifeStep: Float
        var ageStep: Float
    }
    
    let store: Store<LifeSettingState, LifeSettingAction>
    init(store: Store<LifeSettingState, LifeSettingAction>) {
        self.store = store
    }
    
    var body: some View {
                            
        WithViewStore(store.scope(state: \.view)) { viewStore in
            VStack {
                                                                       
                VStack(alignment: .leading, spacing: .py_grid(3)) {
                    Text("Life")
                        .font(Font.preferred(.py_title2()).bold())
                    
                    Text("Set the age you want to achieve all your dreams")
                        .font(Font.preferred(.py_footnote()).bold())
                        .foregroundColor(.gray)
                    
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
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: .py_grid(4))
                                    .fill(Color(.systemRed))
                                    .frame(width: .py_grid(10), height: .py_grid(10))
                            )
                    }
                               
                    
                    Text("Age")
                        .font(Font.preferred(.py_title2()).bold())
                    
                    Text("Set your current age")
                        .font(Font.preferred(.py_footnote()).bold())
                        .foregroundColor(.gray)
                    
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
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: .py_grid(4))
                                    .fill(Color(.systemGreen))
                                    .frame(width: .py_grid(10), height: .py_grid(10))
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
                
                Text("This will allow you to see the progres of your life toward your dreams")
                    .multilineTextAlignment(.center)
                    .font(.preferred(.py_footnote()))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Rectangle().fill(Color(.systemGroupedBackground))
                    )
            
            }
        }
    }
}

struct LifeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LifeSettingView(store: Store(
                initialState: LifeSettingState(),
                reducer: lifeSettingReducer,
                environment: ()
            )).navigationBarTitle(Text("Life Progress"))
            .navigationBarItems(trailing:
                                    Button(action: {}, label: {
                                        Text("Done")
                                            .foregroundColor(.white)
                                            .font(.preferred(.py_headline()))
                                            .padding()
                                            .background(
                                                Capsule().fill(Color.green)
                                            )
                                    })
            )
        }
    }
}
