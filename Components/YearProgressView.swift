import SwiftUI
import Core
import ComposableArchitecture
import TimeClient
import Combine

struct YearState: Equatable {
    var year: Int
    var remainingDays: Int
    var remainingHours: Int
    var percent: Double
    var style: ProgressStyle
    enum ProgressStyle: Equatable { case bar, circle }
    public init(
        year: Int = .zero,
        remainingDays: Int = .zero,
        remainingHours: Int = .zero,
        style: ProgressStyle = .bar,
        percent: Double = .zero
    ) {
        self.year = year
        self.style = style
        self.remainingDays = remainingDays
        self.remainingHours = remainingHours
        self.percent = percent
    }
}

enum YearAction: Equatable {
    case onAppear
    case setYear(Int)
    case response(YearResponse)
}

struct YearEnvironment {
    let calendar: Calendar
    let date: () -> Date
    let timeClient: TimeClient
}

let yearReducer =
    Reducer<YearState, YearAction, YearEnvironment> { state, action, environment in
    switch action {
    case .onAppear:
        return .concatenate(
            currentYear(environment.calendar, environment.date())
                .map(YearAction.setYear)
                .eraseToEffect(),
            environment.timeClient.yearProgress(
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
                        
        let result = extract(
            case: YearResponse.Result.short,
            from: response.result
        )
        
        state.remainingDays = result.map(\.0) ?? .zero
        state.remainingHours = result.map(\.1) ?? .zero
        
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
            title: remainingTime(remainingDays, remainingHours),
            isCircle: style == .circle
        )
    }
}


let remainingTime: (Int, Int) -> NSAttributedString = { days, hours in
    let mutable = NSMutableAttributedString()
    
    if days != .zero {
        let days = NSMutableAttributedString(
            string: "\(days)",
            attributes: [.font: UIFont.py_title3()]
        )
        days.append(
            NSAttributedString(
                string: "days ",
                attributes: [.font: UIFont.py_headline().italicized]
            )
        )
        mutable.append(days)
    }
    
    if hours != .zero {
        let hours = NSMutableAttributedString(
            string: "\(hours)",
            attributes: [.font: UIFont.py_title3()]
        )
        
        hours.append(
            NSAttributedString(
                string: "hours",
                attributes: [.font: UIFont.py_headline().italicized]
            )
        )
        mutable.append(hours)
    }
    
    
    return mutable
}

struct YearProgressView: View {
    
    struct ViewState: Equatable {
        let year: String
        let percentage: NSNumber
        let title: NSAttributedString
        let isCircle: Bool
    }
    
    let store: Store<YearState, YearAction>
    
    init(store: Store<YearState, YearAction>) {
        self.store = store
    }
    
    var body: some View {
        
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
                    timeClient: TimeClient(
                        yearProgress: { _ in
                            Just(YearResponse(
                                progress: 0.5,
                                result: .short(day: 200, hour: 12, minute: 0)
                            )).eraseToAnyPublisher()
                        })
                )
            )
        ).frame(width: 300, height: 300)
    }
}


struct PLabel: UIViewRepresentable {
            
    @Binding var attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UILabel {
        UILabel()
    }
    func updateUIView(_ textView: UILabel, context: Context) {
        textView.attributedText = attributedText
    }
}

let labelStyle: (UILabel) -> Void = {
    $0.textAlignment = .left
}
