import Foundation
import UIKit
public let widgetStyle: (String, String) -> NSAttributedString = { value, title in
    let attributedString = NSMutableAttributedString(
        string: value,
        attributes: [
            .font: UIFont.py_title2(),
            .foregroundColor: UIColor.label
        ]
    )
    attributedString.append(
        NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.py_subhead().lowerCaseSmallCaps,
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
    )
    return attributedString
}

public let taskCellStyle: (String, String) -> NSAttributedString = { value, title in
    let attributedString = NSMutableAttributedString(
        string: value,
        attributes: [.font: UIFont.py_title3()]
    )
    attributedString.append(
        NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.py_subhead().italicized,
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
    )    
    return attributedString
}
