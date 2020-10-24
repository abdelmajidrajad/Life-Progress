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
    case response(YearResponse)
}

struct YearEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let yearProgress: (YearRequest) -> AnyPublisher<YearResponse, Never>
}

let yearReducer =
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
            title: remainingTime(result),
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
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.title)
                    
                    
                    if viewStore.isCircle {
                        ProgressCircle(
                            color: .gray,
                            lineWidth: 12.0,
                            progress: .constant(viewStore.percentage)
                            
                        ).frame(width: 100, height: 100)
                        .offset(y: -20)
                    } else {
                        ProgressBar(
                            color: .green,
                            progress: .constant(viewStore.percentage)
                        )
                    }
                                                    
                    Spacer()
                                                    
                    HStack(alignment: .bottom) {
                        PLabel(attributedText: .constant(viewStore.title))
                            .fixedSize()
                            
                        Text("remaining")
                            .foregroundColor(.gray)
                            .italic()
                    }
                    
                }.padding()
                .background(
                    RoundedRectangle(
                        cornerRadius: 20.0,
                        style: .continuous
                    ).fill(Color.white)
                    .shadow(radius: 1)
                )
            }.onAppear { viewStore.send(.onAppear) }
            
        }
    }
}

struct YearProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YearProgressView(
            store: Store<YearState, YearAction>(
                initialState: YearState(style: .circle),
                reducer: yearReducer,
                environment: YearEnvironment(
                    calendar: .current,
                    date: Date.init,
                    yearProgress:
                         { _ in
                            Just(YearResponse(
                                progress: 0.5,
                                result: TimeResult( day: 200, hour: 22)
                            )).eraseToAnyPublisher()
                        }
                )
            )
        ).frame(width: 300, height: 300)
    }
}




let remainingTime: (TimeResult) -> NSAttributedString = { result in
    let mutable = NSMutableAttributedString()
    if result.year != .zero {
        mutable.append(
            attributedString(value: "\(result.year)", title: "y")
        )
    }
    if result.month != .zero {
        mutable.append(
            attributedString(value: "\(result.month)", title: "m")
        )
    }
    if result.day != .zero {
        mutable.append(
            attributedString(value: "\(result.day)", title: "d")
        )
    }
    if result.hour != .zero {
        mutable.append(
            attributedString(value: "\(result.hour)", title: "h")
        )
    }
    if result.minute != .zero {
        mutable.append(attributedString(value: "\(result.minute)", title: "min"))
    }
    return mutable
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
                .foregroundColor: UIColor.gray
            ]
        )
    )
    return attributedString
}
