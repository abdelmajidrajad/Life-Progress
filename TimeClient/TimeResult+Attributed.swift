import Foundation.NSAttributedString
import UIKit


public enum TimeStyle {
    case short, long
}

extension TimeResult {
    public func string(
        _ attributedString: (String, String) -> NSAttributedString,
        style: TimeStyle = .short
    )
      -> NSAttributedString {
        let mutable = NSMutableAttributedString()
        if self.year != .zero {
            mutable.append(
                attributedString(
                    "\(self.year)",
                    style == .short ? "y": "year"
                )
            )
        }
        if self.month != .zero {
            mutable.append(
                attributedString(
                    "\(self.month)",
                    style == .short ? "m": "months"
                )
            )
        }
        if self.day != .zero {
            mutable.append(
                attributedString(
                    "\(self.day)",
                    style == .short ? "d": "days"
                )
            )
        }
        if self.hour != .zero {
            mutable.append(
                attributedString(
                    "\(self.hour)",
                    style == .short ? "h": "hours"
                )
            )
        }
        if self.minute != .zero {
            mutable.append(
                attributedString(
                    "\(self.minute)",
                    style == .short ? "min": "minutes"
                )
            )
        }
        
        if self.second != .zero
            && minute != .zero
            && hour != .zero
            && month != .zero
            && year != .zero  {
            mutable.append(
                attributedString(
                    "\(self.second)",
                    style == .short ? "s": "seconds"
                )
            )
        }
        
        return mutable
    }
}

