import SwiftUI

extension EdgeInsets {
    public static var zero: EdgeInsets {
        EdgeInsets(
            top: .zero,
            leading: .zero,
            bottom: .zero,
            trailing: .zero
        )
    }
}

extension EdgeInsets {
    public static func bottom(_ edge: CGFloat) -> EdgeInsets {
        EdgeInsets(
            top: .zero,
            leading: .zero,
            bottom: edge,
            trailing: .zero
        )
    }
}

extension EdgeInsets {
    public static func top(_ edge: CGFloat) -> EdgeInsets {
        EdgeInsets(
            top: edge,
            leading: .zero,
            bottom: .zero,
            trailing: .zero
        )
    }
}

extension EdgeInsets {
    public static func leading(_ edge: CGFloat) -> EdgeInsets {
        EdgeInsets(
            top: .zero,
            leading: edge,
            bottom: .zero,
            trailing: .zero
        )
    }
}

extension EdgeInsets {
    public static func trailing(_ edge: CGFloat) -> EdgeInsets {
        EdgeInsets(
            top: .zero,
            leading: .zero,
            bottom: .zero,
            trailing: edge
        )
    }
}
