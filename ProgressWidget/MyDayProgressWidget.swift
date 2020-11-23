import WidgetKit
import SwiftUI
import Intents
import ComposableArchitecture
import Combine

struct MyDayProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> MyDayEntry {
        MyDayEntry(
            state: YourDayProgressState(
                timeResult: .init(hour: 08, minute: 50),
                style: .bar,
                percent: 0.8
            ),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (MyDayEntry) -> ()) {
        let entry = MyDayEntry(
            state: YourDayProgressState(
                timeResult: .init(hour: 08, minute: 50),
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
        completion: @escaping (Timeline<MyDayEntry>) -> ()) {
        let halfHour: TimeInterval = 60 * 30
        var currentDate = Date()
        let endDate = Calendar.current.dayEnd(of: currentDate)
        var entries: [MyDayEntry] = []
        let myDayState = YourDayProgressState(
            style: configuration.style == .bar ? .bar: .circle
        )

        while currentDate < endDate {
            
            let store = Store(
                initialState: myDayState,
                reducer: yourDayProgressReducer,
                environment: SharedEnvironment
                    .shared
                    .yourDay
            )
            
            let viewStore = ViewStore(store)
            
            viewStore.send(.onChange)
            
            let entry = MyDayEntry(
                state: viewStore.state,
                configuration: configuration
            )
            
            currentDate += halfHour
            
            entries.append(entry)
        }
                            
        let timeline = Timeline(
            entries: entries, policy: .atEnd
        )
        
        completion(timeline)
    }
}


struct MyDayEntry: TimelineEntry {
    var date: Date {
        Date()
    }
    let state: YourDayProgressState
    let configuration: ConfigurationIntent
}


struct MyDayProgressWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    let entry: MyDayProvider.Entry
    
    init(entry: MyDayProvider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            YourDayProgressView(
                store: Store(
                    initialState: entry.state,
                    reducer: .empty,
                    environment: ()
                )
            )
        default:
            Text(entry.date, style: .time)
        }
    }
}

struct MyDayProgressWidget: Widget {
    
    let kind: String = "MyDayProgressWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: MyDayProvider(),
            content: MyDayProgressWidgetEntryView.init(entry:)
        ).configurationDisplayName("My Day Progress")
         .description("Track Your Day Progress")
         .supportedFamilies([.systemSmall])
    }
}

import TimeClient
struct MyDayProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MyDayProgressWidgetEntryView(
                entry: MyDayEntry(
                    state: YourDayProgressState(),
                    configuration: ConfigurationIntent()
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

