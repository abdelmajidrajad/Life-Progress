import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine

public struct YearState: Equatable {
    var year: Int
    var result: TimeResult
    var percent: Double
    var style: ProgressStyle    
    public init(
        year: Int = .zero,
        result: TimeResult = .init(),
        style: ProgressStyle = .bar,
        percent: Double = .zero
    ) {
        self.year = year
        self.style = style
        self.result = result
        self.percent = percent
    }
}

public enum YearAction: Equatable {
    case onChange
    case setYear(Int)
    case response(TimeResponse)
}

public struct YearEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let yearProgress: (YearRequest) -> AnyPublisher<TimeResponse, Never>
    public init(
        calendar: Calendar,
        date: @escaping () -> Date,
        yearProgress: @escaping (YearRequest) -> AnyPublisher<TimeResponse, Never>
    ) {
        self.calendar = calendar
        self.date = date
        self.yearProgress = yearProgress
    }
}

public let yearReducer =
    Reducer<YearState, YearAction, YearEnvironment> { state, action, environment in
    switch action {
    case .onChange:
        return .concatenate(
            environment
                .calendar
                .currentYear(environment.date())
                .map(YearAction.setYear)
                .eraseToEffect(),
            environment.yearProgress(
                YearRequest(date: environment.date(),
                            calendar: environment.calendar,
                            resultType: .short
                )).map(YearAction.response)
                .eraseToEffect()
        )
    case let .setYear(year):
        state.year = year
        return .none
    case let .response(response):
        state.percent = response.progress
        state.result = response.result
        return .none
    }
}

extension Calendar {
    var currentYear: (Date) -> Effect<Int, Never> {
        return {
            Effect(
                value: self.dateComponents([.year], from: $0).year!)
        }
    }
}


extension YearState {
    var view: YearProgressView.ViewState {
        YearProgressView.ViewState(
            year: "\(year)",
            percentage: NSNumber(value: percent),
            result: result,
            statusDescription: percent < 1.0
                ? "remaining"
                : "ended",
            isCircle: style == .circle
        )
    }
}

public struct YearProgressView: View {
    
    struct ViewState: Equatable {
        let year: String
        let percentage: NSNumber
        let result: TimeResult
        let statusDescription: String
        let isCircle: Bool
    }
    
    let store: Store<YearState, YearAction>
    
    public init(store: Store<YearState, YearAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            HStack(spacing: .py_grid(2)) {
                
                VStack(alignment: .leading) {
                    
                    Text(viewStore.year)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .trailing
                        ).font(.footnote)
                                        
                    if viewStore.isCircle {
                        ProgressCircle(
                            color: .green,
                            lineWidth: .py_grid(3),
                            progress: .constant(viewStore.percentage)
                        ).frame(
                            width: .py_grid(17),
                            height: .py_grid(17)
                        ).offset(y: -.py_grid(5))
                        
                    } else {
                        ProgressBar(
                            color: .green,
                            progress: .constant(viewStore.percentage)
                        )
                    }
                                                    
                    Spacer()
                                                    
                    HStack(
                        alignment: .lastTextBaseline,
                        spacing: 2
                    ) {
                        
                        buildText(from: viewStore.result)
                            .layoutPriority(1)
                                                    
                        Text(viewStore.statusDescription)
                            .font(.preferred(.py_caption2()))
                            .foregroundColor(Color(.secondaryLabel))
                            .italic()
                            .lineLimit(1)
                        
                    }.frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    
                }.padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: .py_grid(4),
                        style: .continuous
                    ).stroke(Color(.secondaryLabel).opacity(0.2))
                    .shadow(radius: 1)
                    
                )
            }.onAppear { viewStore.send(.onChange) }
            .background(
                Color(.systemBackground)
                    .cornerRadius(.py_grid(5))
            )
            
        }
    }
}

struct YearProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            YearProgressView(
                store: Store<YearState, YearAction>(
                    initialState: YearState(style: .circle),
                    reducer: yearReducer,
                    environment: YearEnvironment(
                        calendar: .current,
                        date: Date.init,
                        yearProgress:
                             { _ in
                                Just(TimeResponse(
                                    progress: 0.5,
                                    result: TimeResult( day: 20, hour: 22)
                                )).eraseToAnyPublisher()
                            }
                    )
                )
            ).frame(width: 141, height: 141)
            YearProgressView(
                store: Store<YearState, YearAction>(
                    initialState: YearState(style: .bar),
                    reducer: yearReducer,
                    environment: YearEnvironment(
                        calendar: .current,
                        date: Date.init,
                        yearProgress:
                             { _ in
                                Just(TimeResponse(
                                    progress: 0.5,
                                    result: TimeResult(
                                        day: 200,
                                        hour: 22
                                    )
                                )).eraseToAnyPublisher()
                            }
                    )
                )
            ).preferredColorScheme(.dark).frame(width: 141, height: 141)
            
            
            VStack {
                PLabel(attributedText: .constant(
                    TimeResult(year: 300, month: 12, day: 1, hour: 1, minute: 1).string(mockStyle)
                ))
                
                PLabel(attributedText: .constant(
                    TimeResult(year: 300, month: 12, day: 1, hour: 1, minute: 1).string(mockStyle)
                ))//.preferredColorScheme(.dark)
            }
        }
    }
}

public let mockStyle: (String, String) -> NSAttributedString = { value, title in
    let attributedString = NSMutableAttributedString(
        string: value,
        attributes: [
            .font: UIFont.py_title2(),
            .foregroundColor: UIColor.label
        ]
    )
    attributedString.append(
        NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.py_subhead().lowerCaseSmallCaps,
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
    )
    return attributedString
}

