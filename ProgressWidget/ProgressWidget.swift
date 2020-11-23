import WidgetKit
import SwiftUI
import Intents
import ComposableArchitecture


extension SharedEnvironment {
    var day: DayEnvironment {
        DayEnvironment(
            calendar: calendar,
            date: date,
            todayProgress: timeClient.todayProgress
        )
    }
}

extension Calendar {
    public func dayEnd(of today: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: self.startOfDay(for: today))!
    }
}

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(
            dayState: DayState(
                timeResult: .init(hour: 10, minute: 30),
                style: .circle,
                percent: 0.7
            ),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(
            dayState: DayState(
                timeResult: .init(hour: 10, minute: 30),
                style: .circle,
                percent: 0.7
            ),
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<DayEntry>) -> ()) {
        let thirtyMinute: TimeInterval = 60 * 5
        var currentDate = Date()
        let endDate = Calendar.current.dayEnd(of: currentDate)
        var entries: [DayEntry] = []
        let dayState = DayState(
            style: configuration.style == .bar ? .bar: .circle
        )

        while currentDate < endDate {
                                    
            let store = Store(
                initialState: dayState,
                reducer: dayReducer,
                environment: SharedEnvironment
                    .shared
                    .day
            )
            
            let viewStore = ViewStore(store)
            
            viewStore.send(.onChange)
            
            let entry = DayEntry(
                dayState: viewStore.state,
                configuration: configuration
            )
            
            currentDate += thirtyMinute
            
            entries.append(entry)
        }
                            
        let timeline = Timeline(
            entries: entries, policy: .atEnd
        )
        
        completion(timeline)
    }
}
import CoreData
struct DayEntry: TimelineEntry {
    var date: Date {
        Date()
    }
    let dayState: DayState
    let configuration: ConfigurationIntent
}

import TimeClient
import Combine

struct DayProgressWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    let entry: Provider.Entry
    
    init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
//            DayProgressView(
//                store: Store(
//                    initialState: entry.dayState,
//                    reducer: .empty,
//                    environment: ()
//                )
//            )
        
            Text(String(entry.dayState.percent))        
        default:
            Text(entry.date, style: .time)
        }
    }
}

struct ToDayProgressWidget: Widget {
                    
    let kind: String = "TodayProgressWidget"
                   
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()) { entry in
            DayProgressWidgetEntryView(
                entry: entry
            )
        }
        .configurationDisplayName("Today Progress")
        .description("Track Today Progress")
        .supportedFamilies([.systemSmall])
    }
}

struct DayProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DayProgressWidgetEntryView(
                entry: DayEntry(
                    dayState: DayState(style: .circle, percent: 0.3),
                    configuration: ConfigurationIntent()
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
