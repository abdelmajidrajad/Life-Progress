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
    case onAppear
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
    case .onAppear:
        return .concatenate(
            currentYear(environment.calendar, environment.date())
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


let currentYear: (Calendar, Date) -> Just<Int> = { calendar, date in
    Just(calendar.dateComponents([.year], from: date).year!)
}

extension YearState {
    var view: YearProgressView.ViewState {
        YearProgressView.ViewState(
            year: "\(year)",
            percentage: NSNumber(value: percent),
            title: result.string,
            isCircle: style == .circle
        )
    }
}

public struct YearProgressView: View {
    
    struct ViewState: Equatable {
        let year: String
        let percentage: NSNumber
        let title: NSAttributedString
        let isCircle: Bool
    }
    
    let store: Store<YearState, YearAction>
    
    public init(store: Store<YearState, YearAction>) {
        self.store = store
    }
    
    public var body: some View {
        
        WithViewStore(store.scope(state: \.view)) { viewStore in
            HStack(spacing: 8.0) {
                
                VStack(alignment: .leading) {
                    
                    Text(viewStore.year)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .trailing
                        ).font(.footnote)
                                        
                    if viewStore.isCircle {
                        ProgressCircle(
                            color: .green,
                            lineWidth: 10.0,
                            progress: .constant(viewStore.percentage)
                        ).frame(width: 60, height: 60)
                        .offset(y: -20)
                    } else {
                        ProgressBar(
                            color: .green,
                            progress: .constant(viewStore.percentage)
                        )
                    }
                                                    
                    Spacer()
                                                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        PLabel(attributedText: .constant(viewStore.title))
                            .fixedSize()
                            
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                            .lineLimit(1)
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    
                }.padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: 20.0,
                        style: .continuous
                    ).stroke(Color.white)
                    .shadow(radius: 1)
                )
            }.onAppear { viewStore.send(.onAppear) }
            
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
                                    result: TimeResult( day: 200, hour: 22)
                                )).eraseToAnyPublisher()
                            }
                    )
                )
            ).frame(width: 141, height: 141)
        }
    }
}




extension TimeResult {
    var string: NSAttributedString {
        let mutable = NSMutableAttributedString()
        if self.year != .zero {
            mutable.append(
                attributedString(
                    value: "\(self.year)",
                    title: "y"
                )
            )
        }
        if self.month != .zero {
            mutable.append(
                attributedString(
                    value: "\(self.month)",
                    title: "m"
                )
            )
        }
        if self.day != .zero {
            mutable.append(
                attributedString(
                    value: "\(self.day)",
                    title: "d"
                )
            )
        }
        if self.hour != .zero {
            mutable.append(
                attributedString(
                    value: "\(self.hour)",
                    title: "h"
                )
            )
        }
        if self.minute != .zero {
            mutable.append(
                attributedString(
                    value: "\(self.minute)",
                    title: "min")
            )
        }
        return mutable
    }
}




func attributedString(value: String, title: String) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(
        string: value,
        attributes: [.font: UIFont.py_title1()]
    )
    attributedString.append(
        NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.py_headline().italicized,
                .foregroundColor: UIColor.darkGray
            ]
        )
    )
    return attributedString
}
