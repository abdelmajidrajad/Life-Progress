import SwiftUI

extension LocalizedStringKey {
    
    static var newTask: LocalizedStringKey {
        localizable("new_task", comment: "new task")        
    }
    
    static var taskTitle: LocalizedStringKey {
        localizable("task_title", comment: "START")
    }
    
    static var startDate: LocalizedStringKey {
        localizable("start_date", comment: "START")
    }
    static var endDate: LocalizedStringKey {
        localizable("end_date", comment: "START")
    }
    static var progressColor: LocalizedStringKey {
        localizable("progress_color", comment: "START")
    }
    static var styleLabel: LocalizedStringKey {
        localizable("style_label", comment: "START")
    }
    static var dayLabel: LocalizedStringKey {
        localizable("day_label", comment: "START")
    }
    static var hourLabel: LocalizedStringKey {
        localizable("hour_label", comment: "START")
    }
    static var monthLabel: LocalizedStringKey {
        localizable("month_label", comment: "START")
    }
    static var yearLabel: LocalizedStringKey {
        localizable("year_label", comment: "START")
    }
    static var startLabel: LocalizedStringKey {
        localizable("start_label", comment: "START")
    }
}



func localizable(_ id: String, comment: String, substitutions: [String: String] = [:]) -> LocalizedStringKey {
    let text = NSLocalizedString(
        id,
        tableName: nil,
        bundle: .tasks,
        value: id,
        comment: comment
    )
    return LocalizedStringKey(
        substitute(text, with: substitutions)
    )
}

private func substitute(_ string: String, with substitutions: [String: String]) -> String {
    substitutions.reduce(string) { accum, sub in
        return accum.replacingOccurrences(of: "%{\(sub.0)}", with: sub.1)
    }
}
