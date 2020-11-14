import WidgetKit
import SwiftUI
import Intents
import ComposableArchitecture

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            store:  Store(
                initialState: DayState(percent: 0.3),
                reducer: dayReducer,
                environment: DayEnvironment(
                    calendar: .current,
                    date: Date.init,
                    todayProgress: { _ in
                        Just(
                        TimeResponse(
                            progress: 0.2,
                            result: TimeResult(hour: 12)
                        )).eraseToAnyPublisher()
                    }))
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            store: Store(
                initialState: DayState(percent: 0.3),
                reducer: dayReducer,
                environment: DayEnvironment(
                    calendar: .current,
                    date: Date.init,
                    todayProgress: { _ in
                        Just(
                        TimeResponse(
                            progress: 0.2,
                            result: TimeResult(hour: 12)
                        )).eraseToAnyPublisher()
                    }))
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                configuration: configuration,
                store: Store(
                    initialState: DayState(percent: 0.3),
                    reducer: dayReducer,
                    environment: DayEnvironment(
                        calendar: .current,
                        date: Date.init,
                        todayProgress: { _ in
                            Just(
                            TimeResponse(
                                progress: 0.2,
                                result: TimeResult(hour: 12)
                            )).eraseToAnyPublisher()
                        }))
            )
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let store: Store<DayState, DayAction>
}

import TimeClient
import Combine

struct ProgressWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            DayProgressView(store: entry.store)
        case .systemMedium:
            Text(entry.date, style: .time)
        case .systemLarge:
            Text(entry.date, style: .time)
        @unknown default:
            Text(entry.date, style: .time)
        }
    }
}

@main
struct ProgressWidget: Widget {
                    
    let kind: String = "ProgressWidget"
               
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()) { entry in
            ProgressWidgetEntryView(
                entry: entry
            )
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    configuration: ConfigurationIntent(),
                    store: Store(
                        initialState: DayState(
                            timeResult: TimeResult(month: 3),
                            percent: 0.3
                        ),
                        reducer: dayReducer,
                        environment: DayEnvironment(
                            calendar: .current,
                            date: Date.init,
                            todayProgress: { _ in
                                Just(
                                    TimeResponse(
                                        progress: 0.2,
                                        result: TimeResult(hour: 12)
                                    )).eraseToAnyPublisher()
                            }))
                    )
                )
                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            ProgressWidgetEntryView(
//                entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
//            ProgressWidgetEntryView(
//                entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
