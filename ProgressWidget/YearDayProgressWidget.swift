//import WidgetKit
//import SwiftUI
//import Intents
//import ComposableArchitecture
//import Combine
//
//struct YearDayProvider: IntentTimelineProvider {
//    
//    func placeholder(in context: Context) -> YearDayEntry {
//        YearDayEntry(
//            state: SwitchState(
//                timeResult: .init(day: 45, hour: 10, minute: 20),
//                dayResult: .zero,
//                style: .bar,
//                yearPercent: 0.7,
//                todayPercent: 0.7,
//                year: 2020
//            ),
//            configuration: ConfigurationIntent()
//        )
//    }
//
//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (YearDayEntry) -> ()) {
//        let entry = YearDayEntry(
//            state: SwitchState(
//                timeResult: .init(day: 45, hour: 10, minute: 20),
//                dayResult: .zero,
//                style: .bar,
//                yearPercent: 0.7,
//                todayPercent: 0.7,
//                year: 2020
//            ),
//            configuration: configuration
//        )
//        completion(entry)
//    }
//
//    func getTimeline(
//        for configuration: ConfigurationIntent,
//        in context: Context,
//        completion: @escaping (Timeline<YearDayEntry>) -> ()) {
//        let halfHour: TimeInterval = 60 * 30
//        var currentDate = Date()
//        let endDate = Calendar.current.dayEnd(of: currentDate)
//        var entries: [YearDayEntry] = []
//        let YearDayState = SwitchState(
//            style: configuration.style == .bar ? .bar: .circle
//        )
//
//        while currentDate < endDate {
//            
//            let store = Store(
//                initialState: YearDayState,
//                reducer: switchReducer,
//                environment: SharedEnvironment
//                    .shared
//                    .union
//            )
//            
//            let viewStore = ViewStore(store)
//            
//            viewStore.send(.onChange)
//            
//            let entry = YearDayEntry(
//                state: viewStore.state,
//                configuration: configuration
//            )
//            
//            currentDate += halfHour
//            
//            entries.append(entry)
//        }
//                            
//        let timeline = Timeline(
//            entries: entries, policy: .atEnd
//        )
//        
//        completion(timeline)
//    }
//}
//
//
//struct YearDayEntry: TimelineEntry {
//    var date: Date {
//        Date()
//    }
//    let state: SwitchState
//    let configuration: ConfigurationIntent
//}
//
//
//struct YearDayProgressWidgetEntryView : View {
//    
//    @Environment(\.widgetFamily) var widgetFamily
//    
//    let entry: YearDayProvider.Entry
//    
//    init(entry: YearDayProvider.Entry) {
//        self.entry = entry
//    }
//    
//    var body: some View {
//        switch widgetFamily {
//        case .systemSmall:
//            SwitchProgressView(
//                store: Store(
//                    initialState: entry.state,
//                    reducer: .empty,
//                    environment: ()
//                )
//            )
//        default:
//            Text(entry.date, style: .time)
//        }
//    }
//}
//
//struct YearDayProgressWidget: Widget {
//    
//    let kind: String = "YearDayProgressWidget"
//    
//    var body: some WidgetConfiguration {
//        IntentConfiguration(
//            kind: kind,
//            intent: ConfigurationIntent.self,
//            provider: YearDayProvider(),
//            content: YearDayProgressWidgetEntryView.init(entry:)
//        ).configurationDisplayName("Year & Today Progress")
//         .description("Track Today and This Year Progress")
//         .supportedFamilies([.systemSmall])
//    }
//}
//
//import TimeClient
//struct YearDayProgressWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            YearDayProgressWidgetEntryView(
//                entry: YearDayEntry(
//                    state: SwitchState(
//                    ),
//                    configuration: ConfigurationIntent()
//                )
//            )
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//            
//        }
//    }
//}
//
