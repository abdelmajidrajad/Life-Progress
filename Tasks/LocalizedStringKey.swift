import SwiftUI

extension LocalizedStringKey {
    static var taskTitle: LocalizedStringKey {
        LocalizedStringKey("task_title")
    }
    static var startDate: LocalizedStringKey {
        LocalizedStringKey("start_date")
    }
    static var endDate: LocalizedStringKey {
        LocalizedStringKey("end_date")
    }
    static var progressColor: LocalizedStringKey {
        LocalizedStringKey("progress_color")
    }
    static var styleLabel: LocalizedStringKey {
        LocalizedStringKey("style_label")
    }
    static var dayLabel: LocalizedStringKey {
        LocalizedStringKey("day_label")
    }
    static var hourLabel: LocalizedStringKey {
        LocalizedStringKey("hour_label")
    }
    static var monthLabel: LocalizedStringKey {
        LocalizedStringKey("month_label")
    }
    static var yearLabel: LocalizedStringKey {
        LocalizedStringKey("year_label")
    }
    static var startLabel: LocalizedStringKey {
        LocalizedStringKey("start_label")
    }
}

extension String {
    public static var taskTitle: Self {
        localizable("task_title", comment: "task title")
    }
}


func localizable(_ id: String, comment: String, substitutions: [String: String] = [:]) -> String {
    let text = NSLocalizedString(
        id,
        tableName: nil,
        bundle: .tasks,
        value: id,
        comment: comment
    )
    return substitute(text, with: substitutions)
}

private func substitute(_ string: String, with substitutions: [String: String]) -> String {
    substitutions.reduce(string) { accum, sub in
        return accum.replacingOccurrences(of: "%{\(sub.0)}", with: sub.1)
    }
}
