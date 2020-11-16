import WidgetKit
import SwiftUI
import Intents

@main
struct ProgressBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        YearProgressWidget()
        DayProgressWidget()
        LifeProgressWidget()
        MyDayProgressWidget()
    }
}
