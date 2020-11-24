import UIKit

public struct ProgressTask: Identifiable, Equatable {
    public var id: UUID
    public let title: String
    public var startDate: Date
    public var endDate: Date
    public var creationDate: Date
    public let color: UIColor
    public let style: Style
    public enum Style: String, Equatable {
        case bar, circle
    }
    public init(
        id: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        creationDate: Date,
        color: UIColor,
        style: Style = .bar
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.creationDate = creationDate
        self.color = color
        self.style = style
    }
}


