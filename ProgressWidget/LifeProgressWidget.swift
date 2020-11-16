import WidgetKit
import SwiftUI
import Intents
import ComposableArchitecture
import Combine

struct LifeProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> LifeEntry {
        LifeEntry(
            lifeState: LifeProgressState(style: .circle, percent: 0.2),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (LifeEntry) -> ()) {
        let entry = LifeEntry(
            lifeState: LifeProgressState(),
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<LifeEntry>) -> ()) {
        let oneDay: TimeInterval = 60 * 60 * 24
        var currentDate = Date()
        let endDate = Calendar.current.dayEnd(of: currentDate)
        var entries: [LifeEntry] = []
        let lifeState = LifeProgressState(
            style: configuration.style == .bar ? .bar: .circle
        )

        while currentDate < endDate {
            
            let store = Store(
                initialState: lifeState,
                reducer: lifeReducer,
                environment: AppEnvironment.live.life
            )
            
            
            
            
            let viewStore = ViewStore(store)
            
            viewStore.send(.onChange)
            
            let entry = LifeEntry(
                lifeState: viewStore.state,
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


struct LifeEntry: TimelineEntry {
    var date: Date {
        Date()
    }
    let lifeState: LifeProgressState
    let configuration: ConfigurationIntent
}


struct LifeProgressWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    let entry: LifeProvider.Entry
    
    init(entry: LifeProvider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            LifeProgressView(
                store: Store(
                    initialState: entry.lifeState,
                    reducer: .empty,
                    environment: ()
                )
            )
        default:
            Text(entry.date, style: .time)
        }
    }
}

struct LifeProgressWidget: Widget {
    
    let kind: String = "LifeProgressWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: LifeProvider(), content: LifeProgressWidgetEntryView.init(entry:)
        )
        .configurationDisplayName("Your Life Progress")
        .description("Track Your Life Progress")
        .supportedFamilies([.systemSmall])
    }
}

import TimeClient
struct LifeProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LifeProgressWidgetEntryView(
                entry: LifeEntry(
                    lifeState: LifeProgressState(
                        timeResult: TimeResult(year: 19, month: 12),
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

