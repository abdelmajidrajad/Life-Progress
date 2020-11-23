import WidgetKit
import SwiftUI
import Intents
import ComposableArchitecture
import Combine

struct YearProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> YearEntry {
        YearEntry(
            yearState: YearState(
               
            ),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (YearEntry) -> ()) {
        let entry = YearEntry(
            yearState: YearState(
                year: 2020,
                result: .init(month: 2, day: 10),
                style: .bar,
                percent: 0.8
            ),
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<YearEntry>) -> ()) {
        let oneDay: TimeInterval = 60 * 60 * 24
        var currentDate = Date()
        let endDate = Calendar.current.dayEnd(of: currentDate)
        var entries: [YearEntry] = []
        let yearState = YearState(
            style: configuration.style == .bar ? .bar: .circle
        )

        while currentDate < endDate {
            
            let store = Store(
                initialState: yearState,
                reducer: yearReducer,
                environment: SharedEnvironment
                    .shared
                    .year
            )
            
            let viewStore = ViewStore(store)
            
            viewStore.send(.onChange)
            
            let entry = YearEntry(
                yearState: viewStore.state,
                configuration: configuration
            )
            
            currentDate += oneDay
            
            entries.append(entry)
        }
                            
        let timeline = Timeline(
            entries: entries, policy: .atEnd
        )
        
        completion(timeline)
    }
}


struct YearEntry: TimelineEntry {
    var date: Date {
        Date()
    }
    let yearState: YearState
    let configuration: ConfigurationIntent
}



struct YearProgressWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    let entry: YearProvider.Entry
    
    init(entry: YearProvider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            YearProgressView(
                store: Store(
                    initialState: entry.yearState,
                    reducer: .empty,
                    environment: ()
                )
            )
        default:
            Text(entry.date, style: .time)
        }
    }
}

struct YearProgressWidget: Widget {
                    
    let kind: String = "YearProgressWidget"
                   
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: YearProvider()) { entry in
            YearProgressWidgetEntryView(
                entry: entry
            )
        }
        .configurationDisplayName("Year Progress")
        .description("Track This Year Progress")
        .supportedFamilies([.systemSmall])
    }
}

import TimeClient
struct YearProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            YearProgressWidgetEntryView(
                entry: YearEntry(
                    yearState: YearState(
                        year: 2002,
                        result: TimeResult(year: 2),
                        style: .bar,
                        percent: 0.3
                    ),
                    configuration: ConfigurationIntent()
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

